-- 5-2 낙찰
-- 낙찰은 판매자가 배송을 보내고 한철수가 배송 수령완료를 입력해야 포인트 이전완성
-- 지금은 상위 입찰자 등장 후 낙찰시간 종료시 낙찰자로 지정하는 상황

-- 경매 물품 낙찰 프로시저
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

    /* 1) 대상 경매 선점: 마감 경매 선택 후 잠금 */
    UPDATE auction_item
       SET bid_status = 'F',
           updated_at = NOW()
     WHERE auction_id = p_auction_id
       AND (
			       bid_status = 'B'
			    OR bid_status IS NULL
			)
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

-- 경매시간 종료 감지 프로시저

DELIMITER //

CREATE PROCEDURE sp_close_auctions()
BEGIN
    DECLARE v_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT auction_id
          FROM auction_item
         WHERE auction_end_time <= NOW(6)
            AND (
			       bid_status = 'B'
			    OR bid_status IS NULL
			)
         ORDER BY auction_end_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL sp_close_one_auction(v_id);
    END LOOP;
    CLOSE cur;
END;
//
DELIMITER ; 

-- 한 번만: 이벤트 스케줄러 ON (권한 필요)
SET GLOBAL event_scheduler = ON;

-- 매 1분마다 종료 경매 정산
-- DROP EVENT IF EXISTS ev_close_auctions;
CREATE EVENT ev_close_auctions
    ON SCHEDULE EVERY 1 MINUTE
    DO
      CALL sp_close_auctions();


-- 낙찰 및 유찰은 1분마다 종료시간 도달 시 자동 처리
-- 경매 수기 종료
CALL sp_close_one_auction(1);