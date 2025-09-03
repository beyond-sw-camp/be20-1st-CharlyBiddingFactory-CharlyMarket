-- 6. 배송 
-- 최소 조건 : 낙찰 경매 물품, 입찰 및 판매 유저

-- 배송 완료 후 처리 트리거
DELIMITER //

CREATE TRIGGER trg_delivery_done
AFTER UPDATE ON delivery
FOR EACH ROW
BEGIN
    DECLARE v_price INT;
    DECLARE v_bid_id INT;
    DECLARE v_remain_sp INT;
	DECLARE v_seller_bp INT;
	DECLARE v_seller_new_bp INT;

    /* 배송 상태가 'S'로 갓 변경된 경우만 처리 (중복 방지) */
    IF NEW.delivery_status = 'S' AND (OLD.delivery_status IS NULL OR OLD.delivery_status <> 'S') THEN

        /* 1) 낙찰 금액/낙찰 bid_id 확보 (경매행 잠금) */
        SELECT current_price, auction_id
          INTO v_price, v_bid_id
          FROM auction_item
         WHERE auction_id = NEW.auction_id
         FOR UPDATE;

        SET v_price = IFNULL(v_price, 0);

        /* 2) 구매자 보관 포인트 잠금 & 잔액 확인 */
        SELECT IFNULL(stored_point, 0)
          INTO v_remain_sp
          FROM `user`
         WHERE user_id = NEW.receiver_user_id
         FOR UPDATE;
        
        IF v_remain_sp < v_price THEN
            /* 보관 포인트가 모자라면 배송완료 처리 자체를 막음 */
            SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = '보관 포인트가 부족하여 거래 차감을 진행할 수 없습니다.';
        END IF;
                
        /* 3) 판매자 포인트 잠금 & 잔액 확인 */
        SELECT IFNULL(user_balance, 0)
          INTO v_seller_bp
          FROM `user`
         WHERE user_id = NEW.send_user_id
         FOR UPDATE;

        /* 4) 구매자 stored_point 차감 */
        UPDATE `user`
           SET stored_point = stored_point - v_price
         WHERE user_id = NEW.receiver_user_id;

        /* 5) 판매자 point 증가 */
        UPDATE `user`
           SET user_balance = user_balance + v_price
         WHERE user_id = NEW.send_user_id;

        /* 6) 경매 상품 상태를 거래완료로 표시 */
        UPDATE auction_item
           SET bid_status = 'Y'
         WHERE auction_id = NEW.auction_id;

        /* 7) 변경된 판매자 포인트 조회 */
        SELECT IFNULL(user_balance, 0)
          INTO v_seller_new_bp
          FROM `user`
         WHERE user_id = NEW.send_user_id;
         
        /* 8) 포인트 로그 기록 */
        INSERT INTO point_log (
            trade_type, trade_amount, trade_explanation,
            bid_id, user_id, point_amount
        ) VALUES (
            'T',
            v_price,
            '배송 완료 확정',
            v_bid_id,
            NEW.send_user_id,
            v_seller_new_bp 
        );
    END IF;
END;
//
DELIMITER ;

-- 낙찰자 배송지 등록
UPDATE delivery 
	SET delivery_address = '서울 광진구 긴고랑로4길 13',
		  delivery_status = 'E',
          registered_at = NOW()
  WHERE delivery_id = 1;
  
-- 운송장 번호 등록 
UPDATE delivery 
	SET delivery_no = '5231582571234',
		  delivery_status = 'I'
  WHERE delivery_id = 1;
  
  

SELECT * FROM user;
SELECT * FROM delivery;

-- 배송 완료 확인 상태로 변경
UPDATE delivery 
	SET delivery_status = 'S',
        finished_at = NOW()
  WHERE delivery_id = 1;
  
-- 배송끝
