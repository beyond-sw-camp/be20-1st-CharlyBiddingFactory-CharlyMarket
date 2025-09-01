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

-- 즐겨찾기 필터 시 해당 유저 즐겨찾기 목록 조회
DELIMITER //

CREATE PROCEDURE favorite_item(
	IN p_user_id INT
)
BEGIN
	select
		u.user_id AS "유저아이디",
		f.auction_id,
		a.auction_title AS "물품명",
		a.auction_content,
		a.starting_price,
		a.created_at
	FROM favorite f
	JOIN user u ON f.user_id = u.user_id
	JOIN auction_item a ON f.auction_id = a.auction_id
	WHERE p_user_id = u.user_id
	ORDER BY u.user_id, f.auction_id
	LIMIT 10;
END //
DELIMITER ;
