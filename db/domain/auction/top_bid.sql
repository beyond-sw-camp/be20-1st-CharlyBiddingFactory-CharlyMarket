USE charly_market;
DROP PROCEDURE IF EXISTS sp_top_bid;

DELIMITER //

CREATE PROCEDURE sp_top_bid(
    IN p_auction_id INT,
    IN p_user_id    INT,
    IN p_bid_amount INT
)
BEGIN
    DECLARE v_now       DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end       DATETIME;
    DECLARE v_price     INT;      
    DECLARE v_bid_id    INT;
    DECLARE v_point     INT;     
    DECLARE v_prev_uid  INT;    
    DECLARE v_prev_bid  INT;   
    DECLARE v_prev_bid_id INT;
    DECLARE v_cnt         INT;
	DECLARE v_new_balance INT;
	DECLARE v_balance     INT;

    /* 에러 시 롤백하고 원본 에러 재던지기 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 0) 최초 입찰 방지(이 프로시저는 '상위 입찰' 전용) */
    SELECT COUNT(*) INTO v_cnt
      FROM auction_bid
     WHERE auction_id = p_auction_id;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '최초 입찰은 sp_first_bid를 사용하세요.';
    END IF;
    
    /* 1) 경매행 잠금 & 검증 */
    SELECT auction_end_time, current_price
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
    IF p_bid_amount <= IFNULL(v_price, 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '입찰가는 현재가보다 커야 합니다.';
    END IF;
        
    /* 2) 기존 최고입찰자/최고가 조회 (가장 높은 금액, 같으면 최근 bid 우선) */
    SELECT b.user_id, b.bid_amount, b.bid_id
      INTO v_prev_uid, v_prev_bid, v_prev_bid_id
      FROM auction_bid b
     WHERE b.auction_id = p_auction_id
     ORDER BY b.bid_amount DESC, b.bid_id DESC
     LIMIT 1;

    /* 3) 신규 입찰자 가용 포인트 잠금 & 검증 */
    SELECT user_balance
      INTO v_point
      FROM `user`
     WHERE user_id = p_user_id
     FOR UPDATE;
    
    IF v_point IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 사용자입니다.';
    END IF;    
    
    /* 동일인이 또 상향 입찰하는 경우: 추가 홀드가 필요 (증가분만) */
    IF v_prev_uid IS NOT NULL AND v_prev_uid = p_user_id THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 입찰중인 상품입니다.';
    ELSE
        /* 서로 다른 사용자가 상위 입찰하는 일반 케이스 */

        /* 3-1) 신규 입찰자 가용 검증 */
        IF v_point < p_bid_amount THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '포인트가 부족합니다.';
        END IF;

        /* 3-2) 입찰 로그 */
        INSERT INTO auction_bid (auction_id, user_id, bid_amount)
        VALUES (p_auction_id, p_user_id, p_bid_amount);
        SET v_bid_id = LAST_INSERT_ID();

        /* 3-3) 기존 최고입찰자 포인트 반환 (있을 때만 처리) */
        IF v_prev_uid IS NOT NULL THEN
            /* 기존 최고자 행 잠금 */
            SELECT user_id FROM `user` WHERE user_id = v_prev_uid FOR UPDATE;

            UPDATE `user`
               SET user_balance = COALESCE(user_balance,0) + COALESCE(v_prev_bid,0),
                   stored_point = COALESCE(stored_point,0) - COALESCE(v_prev_bid,0)
             WHERE user_id = v_prev_uid;

            SELECT user_balance
              INTO v_balance
              FROM `user`
             WHERE user_id = v_prev_uid;
            
            /* 포인트 이력 (반환/보관해제) */
            INSERT INTO point_log (
                trade_type, trade_amount, trade_explanation,
                bid_id, user_id, point_amount
            ) VALUES (
                'R',
                v_prev_bid,
                '상위 입찰에 의한 포인트 반환',
                v_prev_bid_id,
                v_prev_uid,
                v_balance
            );
        END IF;

        /* 3-4) 신규 입찰자 포인트 보관 */
        UPDATE `user`
           SET user_balance = COALESCE(user_balance,0) - p_bid_amount,
               stored_point = COALESCE(stored_point,0) + p_bid_amount
         WHERE user_id = p_user_id;

        SELECT user_balance
          INTO v_new_balance
          FROM `user`
         WHERE user_id = p_user_id;
                
        /* 포인트 이력 (보관) */
        INSERT INTO point_log (
            trade_type, trade_amount, trade_explanation,
            bid_id, user_id, point_amount
        ) VALUES (
            'B',
            p_bid_amount,
            '상위 입찰 포인트 보관',
            v_bid_id,
            p_user_id,
            v_new_balance
        );
    END IF;

    /* 4) 경매 상태/현재가 갱신 */
    UPDATE auction_item
       SET current_price = p_bid_amount,
           bid_status    = 'B'
     WHERE auction_id = p_auction_id;

    /* 5) 종료 10분 이내면 10분 연장 */
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
CALL sp_top_bid(1, 3, 860000);
