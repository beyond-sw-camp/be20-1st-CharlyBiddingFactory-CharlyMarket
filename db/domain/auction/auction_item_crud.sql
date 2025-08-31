-- AUC_INS_001 경매 물품 등록
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

-- AUC_SRC_001 경매 물품 목록 조회
-- 게시상태가 Y인 경매 물품 목록을 최신순으로 조회
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


-- AUC_SRC_002 경매 물품 상세 조회
-- 선택한 경매 물품의 상세 필드 조회
SELECT 
	   a.auction_title AS "물품명"
	 , a.auction_content AS "물품 설명"
	 , a.created_at AS "게시일시"
	 , a.starting_price AS "시작 입찰가"
	 , a.current_price AS "현재 입찰가"
	 , a.bid_unit AS "입찰 단위"
	 , a.auction_start_time AS "입찰 시작 시간" 
	 , a.auction_end_time AS "입찰 종료 시간"
	 , a.seller_address AS "판매자 주소"
	 , c.category_name AS "카테고리명"
  FROM auction_item a
  JOIN category c USING (category_id)
 WHERE a.auction_id = 1;

-- AUC_SRC_003 경매 물품 검색
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
	ORDER BY created_at DESC 
	LIMIT 10;

END //

DELIMITER ;

CALL category_item_search(2);


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

CALL favorite_item(1);

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
   ORDER BY created_at DESC
	LIMIT 10;
END //
DELIMITER ;

CALL search_by_keyword("아이폰");

-- 최신순, 가격순, 마감 임박순 정렬 조회
-- 최신순
SELECT
		*
FROM auction_item
ORDER BY created_at
LIMIT 10;
-- 가격순
SELECT
		*
FROM auction_item
ORDER BY starting_price
LIMIT 10;

SELECT
		*
FROM auction_item
ORDER BY auction_end_time DESC
LIMIT 10;

-- ----------------------------------------------------------
-- AUC_SRC_006 경매물품 삭제
-- auction_id = 4인 경우로 test

-- 입찰 기록을 지워줌
DELETE FROM auction_bid
WHERE bid_id = 4;


DELIMITER //

CREATE PROCEDURE deactive_auction (
    IN p_auction_id INT
)
BEGIN
    DECLARE v_bid_count INT;

    -- 경매 입찰 수를 확인
    SELECT COUNT(*)
    INTO v_bid_count
    FROM auction_bid
    WHERE bid_id = p_auction_id;

    -- 2. 입찰이 없을 경우에만 비활성화
    IF v_bid_count = 0 THEN
        UPDATE auction_item
        SET posting_status = 'N'
        WHERE auction_id = p_auction_id;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '오류';
    END IF;

END //

DELIMITER ;

call deactive_auction(4);