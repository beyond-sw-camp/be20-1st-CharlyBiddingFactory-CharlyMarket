USE charly_market;
DROP PROCEDURE IF EXISTS sp_first_bid;

DELIMITER //

CREATE PROCEDURE sp_first_bid(
    IN p_auction_id INT,
    IN p_user_id    INT,
    IN p_bid_amount INT
)
BEGIN
    DECLARE v_now  DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end  DATETIME;
    DECLARE v_price INT;
    DECLARE v_bid_id INT;
    DECLARE v_point  INT;
	DECLARE v_balance INT;

    /* 에러 시 롤백하고 원본 에러 재던지기 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 1) 경매 잠금 & 검증 (최초 입찰: 시작가 기준) */
    SELECT auction_end_time, starting_price
      INTO v_end, v_price
      FROM auction_item
     WHERE auction_id = p_auction_id
     FOR UPDATE;

    IF v_end IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 경매입니다.';
    END IF;
    IF v_now >= v_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 종료된 경매입니다.';
    END IF;
    IF p_bid_amount <> IFNULL(v_price, 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '입찰가와 시작가가 동일하지 않습니.';
    END IF;

    /* 2) 사용자 포인트 잠금 & 잔액 확인 */
    SELECT user_balance
      INTO v_point
      FROM `user`
     WHERE user_id = p_user_id
     FOR UPDATE;

    IF v_point IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 사용자입니다.';
    END IF;
    IF v_point < p_bid_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '포인트가 부족합니다.';
    END IF;

    /* 3) 입찰 로그 */
    INSERT INTO auction_bid (auction_id, user_id, bid_amount)
    VALUES (p_auction_id, p_user_id, p_bid_amount);

    SET v_bid_id = LAST_INSERT_ID();

    /* 4) 포인트 보관(가용 ↓, 보관 ↑) */
	UPDATE `user`
   		SET user_balance = COALESCE(user_balance, 0) - p_bid_amount,
 	        stored_point = COALESCE(stored_point, 0) + p_bid_amount
	  WHERE user_id = p_user_id;

    SELECT user_balance 
      INTO v_balance
      FROM `user`
     WHERE user_id = p_user_id;

    /* 5) 포인트 이력 (타임스탬프는 DEFAULT CURRENT_TIMESTAMP 가정) */
    INSERT INTO point_log (
        trade_type, trade_amount, trade_explanation,
        bid_id, user_id, point_amount
    ) VALUES (
        'B',
        p_bid_amount,
        '입찰 포인트 보관',
        v_bid_id,
        p_user_id,
        v_balance
    );

    /* 6) 경매 상태/현재가 갱신 (최초 입찰) */
    UPDATE auction_item
       SET current_price = p_bid_amount,
           bid_status    = 'B'
     WHERE auction_id = p_auction_id;

    /* 7) 종료 10분 이내면 10분 연장 */
    IF TIMESTAMPDIFF(MINUTE, v_now, v_end) <= 10 THEN
        UPDATE auction_item
           SET auction_end_time = DATE_ADD(auction_end_time, INTERVAL 10 MINUTE)
         WHERE auction_id = p_auction_id;
    END IF;

    COMMIT;
END;
//
DELIMITER ;

-- 사용 예시
CALL sp_first_bid(1, 2, 800000);
