-- 1. 등급 (grade) 생성
INSERT INTO grade (grade_name, grade_fee_rate, grade_standard) VALUES
('B', 10.00, 0),
('S', 7.00, 20),
('G', 5.00, 50),
('P', 3.00, 100);


-- 2. 유저 (user) 생성
INSERT INTO user (user_role, id, user_password, user_name, user_phone, user_email, grade_id, user_nickname) VALUES
('USER', 'user01', 'pw01', '홍길동', 01042331101, 'user01@test.com', 1, '길동이'),
('USER', 'user02', 'pw02', '김철수', 01020250202, 'user02@test.com', 2, '철수짱'),
('USER', 'user03', 'pw03', '이영희', 01030530303, 'user03@test.com', 3, '영희공주'),
('USER', 'user04', 'pw04', '박민수', 01043254404, 'user04@test.com', 4, '민수형'),
('ADMIN', 'admin01', 'adminpw01', '관리자1', 999999999, 'admin1@test.com', 4, '운영자1'),
('ADMIN', 'admin02', 'adminpw02', '관리자2', 888888888, 'admin2@test.com', 4, '운영자2');


-- 3. 계좌 (account) 생성
INSERT INTO account (bank_name, account_no, bank_owner, user_id) VALUES
('농협은행', '35608802134234', '홍길동', 1),
('국민은행', '93800200592714', '김철수', 2),
('우리은행', '53454358123525', '이영희', 3),
('신한은행', '13513549534455', '박민수', 4),
('카카오뱅크', '8888888888888', '관리자1', 5),
('카카오뱅크', '9999999999999', '관리자2', 6);


-- 4. 카테고리 (category) 생성
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


-- 5. 알림 템플릿 (alarm_template)
INSERT INTO alarm_template (alarm_content, alarm_status, category_id) VALUES
('경매 시작되었습니다.', 'Y', 15),
('입찰 성공하였습니다.', 'Y', 15),
('입찰 실패되었습니다.', 'Y', 15);



-- 6. 경매 물품 (auction_item)
INSERT INTO auction_item (user_id, auction_title, auction_content, starting_price, bid_unit, seller_address, category_id) VALUES
(1, '아이폰 14', '거의 새상품 팝니다', 800000, 1000, '서울 강남구', 1),
(2, '나이키 운동화', '사이즈 270, 미사용', 90000, 1000, '부산 해운대구', 2),
(3, '삼성 노트북', 'i7 탑재 노트북', 1200000, 5000, '대구 중구', 1),
(4, '소설책 세트', '베스트셀러 모음', 30000, 500, '인천 연수구', 4),
(2, '패딩점퍼', '겨울 필수 아이템', 150000, 2000, '서울 마포구', 2);


-- 7. 입찰 (auction_bid)
INSERT INTO auction_bid (bid_amount, auction_id, user_id) VALUES
(805000, 1, 2),
(810000, 1, 4),
(815000, 1, 3),
(95000, 2, 1),
(1250000, 3, 4),
(32000, 4, 1),
(34000, 4, 1);


-- 8. 즐겨찾기 (favorite)
INSERT INTO favorite (user_id, auction_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5);

-- 9. 결제 로그 (payment_log)
INSERT INTO payment_log (payment_type, account_id, user_id, payment_amount, conversion_amount, grade_name, point_amount) VALUES
('C', 1, 1, 100000, 90000, 'B', 90000),
('C', 2, 2, 200000, 186000, 'S', 186000),
('C', 3, 3, 500000, 475000, 'G', 475000),
('C', 4, 4, 1000000, 970000, 'P', 970000);


-- 10. 리뷰 (review)
INSERT INTO review (review_star, review_content, reviewer_id, reviewee_id, auction_id) VALUES
(5, '빠른 배송 감사합니다!', 1, 2, 1),
(4, '상품 상태 좋아요', 2, 3, 2),
(3, '가격은 좀 비쌌지만 괜찮아요', 3, 1, 3),
(5, '책 상태가 완전 새책 같아요', 4, 2, 4);



-- 11. 공지사항 (notice)
INSERT INTO notice (notice_title, notice_content, user_id) VALUES
('시스템 점검 안내', '내일 오전 2시부터 4시까지 점검이 있습니다.', 5),
('이벤트 안내', '리뷰 이벤트 진행 중입니다.', 5),
('이벤트 안내', '신규가입 이벤트 진행 중입니다.', 6);


-- 12. 문의 (inquiry)
INSERT INTO inquiry (inquiry_title, inquiry_content, user_id) VALUES
('입찰 오류 문의', '입찰이 안돼요', 1),
('포인트 환불 문의', '환불은 어떻게 하나요?',2);


-- 13. 신고 (report)
INSERT INTO report ( report_content, category_id, auction_id, reporter_id) VALUES
( '허위 상품 같아요', 5, 1, 2),
( '사기 의심됩니다', 5, 2, 3),
( '상품 부서졌어요', 5, 3, 1);


-- 14. 배송 (delivery)
INSERT INTO delivery (delivery_address, delivery_no, delivery_status, send_user_id, receiver_user_id, auction_id) VALUES
('서울 강남구 101동 202호', 123456789, 'S', 1, 2, 1),
('부산 해운대구 303동 404호', 987654321, 'S', 2, 3, 2),
('', '', '', 2, 3, 2),
('', '', '', 1, 4, 3);


-- 15. 파일 (file)
INSERT INTO file (auction_id, file_path, file_name, file_type, review_id) VALUES
(1, '/home/charly/image/', 'iphone14', 'jpg', 1),
(2, '/home/charly/image/', 'galaxy25', 'jpg',2 );


-- 16. 포인트 로그 (point_log)
INSERT INTO point_log(trade_type,trade_amount,trade_explanation,bid_id,user_id,point_amount) VALUES
('U',805000, '입찰 시 포인트 차감', 1, 2, 100000),
('T',500000, '최종 낙찰 수령완료 포인트이전', 2, 3, 600000);

-- 17. 회원 로그 (user_log)
INSERT INTO user_log (user_id, user_log_content, column_name) VALUES
(1, '닉네임 변경: 철수짱 → 슈퍼철수', 'user_nickname'),
(2, '전화번호 변경: 010-1111-2222 → 010-3333-4444', 'user_phone'),
(1, '비밀번호 변경 처리', 'user_password'),
(3, '이메일 수정: old@example.com → new@example.com', 'user_email'),
(2, '상태 변경: Y → B(비활성)', 'user_status');


-- 18. 알람 박스 (alaram_box)
INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id, alarm_content)

SELECT
    'N', a.user_id, c.alarm_id, b.auction_id,
    CONCAT(a.user_name, ' 님! ', b.auction_title, ' 의 ', c.alarm_content)
FROM user a
JOIN auction_item b ON b.auction_id = 1
JOIN alarm_template c ON c.alarm_id = 1
WHERE a.user_id = 1

UNION ALL

SELECT
    'Y', a.user_id, c.alarm_id, b.auction_id,
    CONCAT(a.user_name, ' 님! ', b.auction_title, ' 의 ', c.alarm_content)
FROM user a
JOIN auction_item b ON b.auction_id = 2
JOIN alarm_template c ON c.alarm_id = 2
WHERE a.user_id = 2

UNION ALL

SELECT
    'N', a.user_id, c.alarm_id, b.auction_id,
    CONCAT(a.user_name, ' 님! ', b.auction_title, ' 의 ', c.alarm_content)
FROM user a
JOIN auction_item b ON b.auction_id = 2
JOIN alarm_template c ON c.alarm_id = 1
WHERE a.user_id = 3

UNION ALL

SELECT
    'Y', a.user_id, c.alarm_id, b.auction_id,
    CONCAT(a.user_name, ' 님! ', b.auction_title, ' 의 ', c.alarm_content)
FROM user a
JOIN auction_item b ON b.auction_id = 1
JOIN alarm_template c ON c.alarm_id = 2
WHERE a.user_id = 1;
