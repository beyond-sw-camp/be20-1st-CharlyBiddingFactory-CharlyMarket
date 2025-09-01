-- PNT_TRN_003 포인트 이전
-- report 신고 'Y' 처리 및 "판매자에게 환불"처리시
-- 경매 물품 현재 입찰가 판매자에게 이전
-- 현재 입찰가 가격을 넣어줬습니다
UPDATE auction_item
SET current_price = 801000
WHERE auction_id = 1;

DELIMITER $$

CREATE PROCEDURE report_by_point(
    IN p_report_id INT,
    IN p_auction_id INT
)
BEGIN
    DECLARE v_current_price INT;
    DECLARE v_seller_id INT;
    DECLARE v_bid_id INT;

    -- 1️신고 처리: 상태 Y, 처리내용 기록
    UPDATE report -- 신고 처리 상황
    SET report_status = 'Y',
        report_action = '판매자에게 환불'
    WHERE report_id = p_report_id;

    -- 2️경매물품 정보 가져오기
    SELECT current_price, user_id
    INTO v_current_price, v_seller_id
    FROM auction_item
    WHERE auction_id = p_auction_id;

    -- 3️마지막 입찰 ID 가져오기 (포인트 로그용)
    SELECT bid_id
    INTO v_bid_id
    FROM auction_bid
    WHERE auction_id = p_auction_id
    ORDER BY created_at DESC
    LIMIT 1;

    -- 4️point_log에 환불 기록
    INSERT INTO point_log (trade_type, trade_amount, created_at, trade_explanation, bid_id, user_id, point_amount)
    VALUES (
        'T',
        v_current_price,
        NOW(),
        CONCAT('경매 ', p_auction_id, ' 환불 처리'),
        v_bid_id,
        v_seller_id,
        v_current_price + (SELECT user_balance FROM user WHERE user_id = v_seller_id) -- 환불 후 포인트
    );

    -- 5️판매자 잔액 업데이트
    UPDATE user
    SET user_balance = user_balance + v_current_price
    WHERE user_id = v_seller_id;

END $$

DELIMITER ;

-- 신고 ID 1번, 물품 ID 1번 처리
CALL report_by_point(1, 1);