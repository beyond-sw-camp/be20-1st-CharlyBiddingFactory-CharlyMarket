-- AUC_SRC_001 경매물품 목록 조회
-- 게시상태가 Y인 경매 물품 목록 조회
SELECT 
	   auction_title
	 , seller_address 
	 , starting_price
	 , current_price
	 , bid_unit
	 , auction_start_time
	 , auction_end_time
  FROM auction_item 
ORDER BY auction_id DESC 
LIMIT 10;


SELECT 
	   auction_title
	 , seller_address 
	 , starting_price
	 , current_price
	 , bid_unit
	 , auction_start_time
	 , auction_end_time
  FROM auction_item 
ORDER BY auction_id DESC 
LIMIT 10
OFFSET 10; -- 2페이지 