-- 4. 경매등록
-- 4-1. 카테고리 생성
INSERT INTO category (category_type, category_name, category_status) VALUES
('I', '전자제품', 'Y'),
('I', '패션', 'Y'),
('I', '가구', 'Y'),
('I', '도서', 'Y'),
('I', '악기', 'Y'),
('I', '자동차', 'Y'),
('I', '미용', 'Y'),
('I', '스포츠', 'Y'),
('I', '생활', 'Y'),
('I', '가전제품', 'Y'),
('I', '기타', 'Y'),
('I', '식품', 'Y'),
('I', '게임', 'Y'),
('A', '회원', 'Y'),
('A', '경매', 'Y'),
('A', '배송', 'Y'),
('R', '욕설', 'Y'),
('R', '상품불량', 'Y');

SELECT * FROM category;

-- 4-2. 경매 등록
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
	'아이폰14pro 중고',
	'아이폰14pro 새상품 같은 중고 상품 경매합니다.',
	50000,
	1000,
	DATE_ADD(NOW(), INTERVAL 30 MINUTE),
	NOW() + INTERVAL 7 DAY + INTERVAL 30 MINUTE,
	'서울 동작구',
	1
);

SELECT * FROM auction_item;

-- 4.3 즐겨찾기 등록
-- 한철수 즐겨찾기 등록
INSERT INTO favorite (user_id, auction_id) VALUES (4,1);
SELECT * FROM favorite;