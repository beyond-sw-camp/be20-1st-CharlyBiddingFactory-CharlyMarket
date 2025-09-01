-- PNT_SOT_005 포인트 검색
-- 거래유형을 기준으로 조회

SELECT 
    point_log_id,
    trade_type,
    trade_amount,
    created_at,
    trade_explanation,
    bid_id,
    user_id,
    point_amount
FROM point_log
WHERE user_id = 1
ORDER BY trade_type ASC
LIMIT 10;

-- 거래 일시를 기준으로 조회
SELECT 
    point_log_id,
    trade_type,
    trade_amount,
    created_at,
    trade_explanation,
    bid_id,
    user_id,
    point_amount
FROM point_log
WHERE user_id = 1
ORDER BY created_at DESC
LIMIT 10;