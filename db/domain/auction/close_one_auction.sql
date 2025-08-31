USE charly_market;
DROP PROCEDURE IF EXISTS sp_close_one_auction;

DELIMITER //

CREATE PROCEDURE sp_close_one_auction(IN p_auction_id INT)
proc: BEGIN
    DECLARE v_now DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end DATETIME;
    DECLARE v_status CHAR(1);
    DECLARE v_win_uid INT;
    DECLARE v_win_bid INT;
    DECLARE v_win_bid_id INT;
	DECLARE v_seller_uid INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 1) 대상 경매 선점(동시성 방지): 마감됐고 진행 중이며 아직 정산 안 된 건만 L로 전환 */
    UPDATE auction_item
       SET bid_status = 'F'
     WHERE auction_id = p_auction_id
       AND bid_status = 'B'
       AND auction_end_time <= v_now;

    /* 2) 잠금 후 상태 재확인 */
    SELECT auction_end_time, bid_status, user_id
      INTO v_end, v_status, v_seller_uid
      FROM auction_item
     WHERE auction_id = p_auction_id
     FOR UPDATE;

    /* 3) 최고입찰(가장 높은 금액, 동액이면 최근) */
    SELECT MAX(bid_amount) 
      INTO v_win_bid
      FROM auction_bid
     WHERE auction_id = p_auction_id;

    IF v_win_bid IS NULL THEN
        /* 유찰: 입찰 없음 → 종료만 표시 */
        UPDATE auction_item
           SET bid_status = 'N',
           	   posting_status = 'N'
         WHERE auction_id = p_auction_id;
        COMMIT;
        LEAVE proc;
    END IF;

    SELECT user_id, bid_id
      INTO v_win_uid, v_win_bid_id
      FROM auction_bid
     WHERE auction_id = p_auction_id
       AND bid_amount = v_win_bid
     ORDER BY bid_id DESC
     LIMIT 1;

    /* 4) 낙찰 입찰 success='Y' */
    UPDATE auction_bid
       SET success_status = 'Y'
     WHERE bid_id = v_win_bid_id;

    /* 5) 배송(주문) 생성 */
    INSERT INTO delivery (auction_id, receiver_user_id, send_user_id)
    VALUES (p_auction_id, v_win_uid, v_seller_uid);

    COMMIT;
END;
//
DELIMITER ;

CALL sp_close_one_auction(1);
