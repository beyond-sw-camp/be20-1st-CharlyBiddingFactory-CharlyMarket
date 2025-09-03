-- 경매 물품 조회 성능 개선 인덱스
CREATE INDEX idx_auction_item_end_status 
ON auction_item (auction_end_time, bid_status, auction_id);

-- 거래내역 조회 성능 개선 인덱스
CREATE INDEX idx_ab_created_at
ON auction_bid (created_at, auction_id, user_id, bid_amount, success_status);
