-- AUC_INS_001 경매물품 등록
INSERT INTO auction_item 
(
	user_id, 
	auction_title, 
	auction_content, 
	starting_price, 
	bid_unit, 
	auction_start_time, 
	auction_end_time, 
	seller_address, 
	category_id
) VALUES 
(
	1,
	'아이폰13pro',
	'아이폰13pro 미개봉 상품 경매합니다.',
	100000,
	10000,
	DATE_ADD(NOW(), INTERVAL 30 MINUTE),
	NOW() + INTERVAL 7 DAY + INTERVAL 30 MINUTE,
	'서울 동작구',
	1
);