-- AUC_SRC_002 경매물품 상세조회
SELECT 
	   a.auction_title
	 , a.auction_content
	 , a.created_at
	 , a.starting_price
	 , a.current_price
	 , a.bid_unit
	 , a.auction_start_time
	 , a.auction_end_time
	 , a.seller_address
	 , c.category_name
  FROM auction_item a
  JOIN category c USING (category_id)
 WHERE a.auction_id = 1;