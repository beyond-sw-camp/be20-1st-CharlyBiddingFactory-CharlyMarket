-- 카테고리 선택 시 해당 카테고리 목록 조회
DELIMITER //

CREATE PROCEDURE category_item_search (
		IN p_category_id INT 
)
BEGIN
	select
		auction_id,
		category_id,
		auction_title,
		auction_content,
		starting_price,
		current_price,
		bid_status,
		posting_status,
		created_at,
		auction_start_time,
		auction_end_time
	FROM auction_item
	WHERE category_id = p_category_id
	ORDER BY created_at DESC;

END //

DELIMITER ;

CALL category_item_search(2);

-- 키워드 검색 시 해당 키워드 목록 조회
SELECT * FROM auction_item;

INSERT INTO auction_item(user_id, auction_title, auction_content, created_at, starting_price, current_price, bid_unit, seller_address, category_id, posting_status)
VALUES(
	1,
	"아이폰 15",
	"거의 새상품 팝니다",
	NOW(),
	800000,
	850000,
	1000,
	"서울 강남구",
	1,
	"Y"
);

INSERT INTO auction_item(user_id, auction_title, auction_content, created_at, starting_price, current_price, bid_unit, seller_address, category_id, posting_status)
VALUES(
	1,
	"아이폰 16",
	"거의 새상품 팝니다",
	NOW(),
	800000,
	850000,
	1000,
	"서울 강남구",
	1,
	"Y"
);

DELIMITER //
CREATE PROCEDURE search_by_keyword(
	IN p_keyword VARCHAR(100)
)
BEGIN
	select
		 auction_id,
        auction_title,
        auction_content,
        starting_price,
        current_price,
        created_at,
        auction_end_time
   FROM auction_item
   WHERE auction_title LIKE CONCAT("%", p_keyword, "%")
   ORDER BY created_at DESC;
END //
DELIMITER ;

CALL search_by_keyword("아이폰");