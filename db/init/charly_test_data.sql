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
('ADMIN', 'admin01', 'adminpw01', '관리자1', 01099999999, 'admin1@test.com', 4, '운영자1'),
('USER', 'user03', 'pw03', '이영희', 01030530303, 'user03@test.com', 2, '영희공주'),
('USER', 'user04', 'pw04', '박민수', 01043254404, 'user04@test.com', 1, '민수형'),
('USER', 'user05', 'pw05', '김성태', 01023651234, 'user05@test.com', 3, '에겐남'),
('USER', 'user06', 'pw06', '이민욱', 01074424532, 'user06@test.com', 3, '욱이형'),
('USER', 'user07', 'pw07', '유한세', 01066753544, 'user07@test.com', 3, 'MZ'),
('USER', 'user08', 'pw08', '박인수', 01057457422, 'user08@test.com', 3, '키링'),
('USER', 'user09', 'pw09', '박연수', 01076445345, 'user09@test.com', 3, '테토녀'),
('USER', 'user10', 'pw10', '김상재', 01046343454, 'user10@test.com', 3, '옛사람'),
('ADMIN', 'admin02', 'adminpw02', '관리자2', 999999999, 'admin2@test.com', 4, '운영자2'),
('ADMIN', 'admin03', 'adminpw03', '관리자3', 888888888, 'admin3@test.com', 4, '운영자3'),
('USER', 'user11', 'pw11', '최지훈', 01011112222, 'user11@test.com', 1, '지훈이'),
('USER', 'user12', 'pw12', '정수빈', 01022223333, 'user12@test.com', 2, '수비니'),
('USER', 'user13', 'pw13', '오민아', 01033334444, 'user13@test.com', 3, '민아짱'),
('USER', 'user14', 'pw14', '강태현', 01044445555, 'user14@test.com', 1, '태현군'),
('USER', 'user15', 'pw15', '한소희', 01055556666, 'user15@test.com', 2, '소희언니'),
('USER', 'user16', 'pw16', '조영준', 01066667777, 'user16@test.com', 3, '영준형'),
('USER', 'user17', 'pw17', '문가영', 01077778888, 'user17@test.com', 1, '가영스타'),
('USER', 'user18', 'pw18', '신동현', 01088889999, 'user18@test.com', 2, '동현킴'),
('USER', 'user19', 'pw19', '서예린', 01012345678, 'user19@test.com', 3, '예린공주'),
('USER', 'user20', 'pw20', '배성우', 01087654321, 'user20@test.com', 1, '성우짱');


-- 3. 계좌 (account) 생성
INSERT INTO account (bank_name, account_no, bank_owner, user_id) VALUES
('농협은행', '35608802134234', '홍길동', 1),
('국민은행', '93800200592714', '김철수', 2),
('우리은행', '53454358123525', '관리자1', 3),
('신한은행', '13513549534455', '이영희', 4),
('토스뱅크', '31435423576534', '박민수', 5),
('토스뱅크', '54346234435326', '김성태', 6),
('국민은행', '86557456223456', '이민욱', 7),
('농협은행', '12367866443223', '유한세', 8),
('카카오뱅크', '8888888888888', '관리자2', 12),
('카카오뱅크', '9999999999999', '관리자3', 13),
('농협은행', '35608802134234', '홍길동', 1),
('부산은행', '10120230405060', '최지훈', 14),
('신한은행', '20230405060708', '정수빈', 15),
('국민은행', '30340506070809', '오민아', 16),
('우리은행', '40450607080910', '강태현', 17),
('하나은행', '50560708091011', '한소희', 18),
('IBK기업은행', '60670809101112', '조영준', 19),
('카카오뱅크', '70780910111213', '문가영', 20),
('토스뱅크', '80891011121314', '신동현', 21),
('농협은행', '90910111213141', '서예린', 22),
('SC제일은행', '10011213141516', '배성우', 23);


-- 4. 카테고리 (category) 생성
INSERT INTO category (category_type, category_name, category_status) VALUES
('I', '전자제품', 'Y'),
('I', '패션', 'Y'),
('I', '가구', 'Y'),
('I', '도서', 'Y'),
('I', '악기', 'N'),
('I', '자동차', 'Y'),
('I', '미용', 'N'),
('I', '스포츠', 'Y'),
('I', '생활', 'Y'),
('I', '가전제품', 'Y'),
('I', '기타', 'N'),
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
(1, '아이폰 14', '거의 새상품 팝니다', 80000, 1000, '서울 강남구', 1),
(2, '나이키 운동화', '사이즈 270, 미사용', 90000, 1000, '부산 해운대구', 2),
(1, '삼성 노트북', 'i7 탑재 노트북', 1200000, 5000, '대구 중구', 1),
(4, '소설책 세트', '베스트셀러 모음', 30000, 500, '인천 연수구', 4),
(2, '패딩점퍼', '겨울 필수 아이템', 150000, 2000, '서울 마포구', 2),
(6, '아이폰 27', '미래 상품 팔아요', 1980000, 10000, '부산 해운대', 1),
(6, '크록스', '성태 킴의 친필싸인이 담긴 크록스입니다', 800000, 10000, '부산 해운대', 2),
(10, '에어프라이기', '받고 사용하지 않은 새 상품이에요', 500000, 10000, '서울 강남구', 10),
(6, '번개맞은 나뭇가지 팝니다', '천년묵은 번개맞은 나뭇가지 판매합니다', 1000000, 1000, '서울 강남구', 11),
(3, '게이밍 키보드', 'RGB 기계식 키보드입니다', 70000, 1000, '서울 송파구', 1),  
(5, '산악 자전거', 'MTB 풀세트, 거의 새것', 450000, 5000, '경기 성남시', 8), 
(7, '고급 원목 책상', '가구점에서 구매, 상태 좋음', 300000, 5000, '서울 종로구', 3), 
(8, '닌텐도 스위치', '게임기 풀박스 + 게임팩 2개', 280000, 2000, '광주 북구', 13), 
(9, '캠핑 텐트', '4인용 자동텐트, 한번 사용', 120000, 2000, '강원 춘천시', 8),
(11, '베스트셀러 소설 모음', '소설책 20권 세트 판매', 95000, 1000, '대전 서구', 4), 
(12, '가정용 공기청정기', '1년 사용, 필터 새것 교체', 150000, 2000, '서울 구로구', 10), 
(13, 'SUV 중고차', '2009년식, 주행거리 15만km', 3200000, 10000, '경기 수원시', 6), 
(14, '원두 커피 세트', '고급 원두 3종 묶음', 35000, 500, '부산 수영구', 12), 
(15, '드럼 연습 패드 세트', '연습용으로 적합한 드럼 패드', 80000, 1000, '서울 강서구', 5); 

-- 7. 입찰 (auction_bid)
INSERT INTO auction_bid (bid_amount, auction_id, user_id) VALUES
(805000, 1, 2),
(810000, 1, 4),
(815000, 1, 3),
(800000, 7, 1),
(850000, 7, 8),
(900000, 7, 5),
(950000, 7, 8),
(1000000, 7, 1),
(1050000, 7, 5),
(30500, 4, 7),
(31000, 4, 9),
(31500, 4, 10),
(32000, 4, 7),
(820000, 1, 6),
(830000, 1, 9),
(95000, 2, 5),
(100000, 2, 7),
(1205000, 3, 2),
(1210000, 3, 4),
(1220000, 3, 9),
(32500, 4, 11),
(33000, 4, 6),
(460000, 8, 3),
(465000, 8, 10),
(285000, 13, 12),
(290000, 13, 7);



-- 8. 즐겨찾기 (favorite)
INSERT INTO favorite (user_id, auction_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(1, 6),
(1, 9),
(1, 8),
(2, 2),
(9, 8);

-- 9. 결제 로그 (payment_log)
INSERT INTO payment_log (payment_type, account_id, user_id, payment_amount, conversion_amount, grade_name, point_amount) VALUES
('C', 1, 1, 1000000, 900000, 'B', 900000),
('C', 2, 2, 200000, 186000, 'S', 186000),
('C', 3, 3, 500000, 475000, 'G', 475000),
('C', 4, 4, 1000000, 970000, 'P', 970000),
('C', 4, 4, 1000000, 970000, 'P', 970000),
('R', 11, 1, 100000, 90000, 'B', 0),
('C', 5, 5, 500000, 450000, 'B', 450000),
('C', 6, 6, 300000, 270000, 'B', 270000),
('C', 7, 7, 1000000, 930000, 'S', 930000),
('C', 8, 8, 1500000, 1425000, 'G', 1425000),
('C', 1, 1, 500000, 450000, 'B', 1350000),
('R', 2, 2, 100000, 93000, 'S', 93000),
('R', 3, 3, 50000, 47500, 'G', 522500),
('C', 4, 4, 200000, 194000, 'P', 1160000),
('C', 5, 5, 30000, 28500, 'B', 478500),
('R', 6, 6, 150000, 135000, 'B', 135000),
('C', 7, 7, 200000, 186000, 'S', 1116000),
('R', 8, 8, 50000, 47500, 'G', 1377500),
('C', 9, 9, 100000, 95000, 'B', 234500),
('C', 10, 10, 200000, 190000, 'S', 494000);



-- 10. 리뷰 (review)
INSERT INTO review (review_star, review_content, reviewer_id, reviewee_id, auction_id) VALUES
(5, '빠른 배송 감사합니다!', 1, 2, 1),
(4, '상품 상태 좋아요', 2, 3, 2),
(3, '가격은 좀 비쌌지만 괜찮아요', 3, 1, 3),
(2, '냄새가 좀 많이 나요', 8, 6, 7),
(1, '그냥 사기꾼이에요', 9, 6, 6),
(1, '번개말고 그냥 총맞은거 같은데요', 1, 6, 9),
(5, '아이폰 상태 최고네요!', 2, 1, 1),
(4, '운동화 만족합니다', 3, 2, 2),
(3, '노트북 성능 괜찮아요', 4, 1, 3),
(5, '책 내용 알차네요', 5, 4, 4),
(2, '패딩 생각보다 얇아요', 6, 2, 5),
(4, '아이폰 27 기대 이상', 7, 6, 6),
(3, '크록스 디자인 마음에 들어요', 8, 6, 7),
(5, '에어프라이기 활용도 높아요', 9, 10, 8),
(4, '나뭇가지 특이하고 좋네요', 10, 6, 9),
(5, '게이밍 키보드 반응 속도 좋습니다', 1, 3, 10);



-- 11. 공지사항 (notice)
INSERT INTO notice (notice_title, notice_content, user_id) VALUES
('시스템 점검 안내', '내일 오전 2시부터 4시까지 점검이 있습니다.', 3),
('이벤트 안내', '리뷰 이벤트 진행 중입니다.', 3),
('이벤트 안내', '친구 추천하고 포인트 받아가세요!', 3),
('이벤트 안내', '신규가입 이벤트 진행 중입니다.', 12),
('입찰 오류안내', '입찰시스템이 문제가 생겨서 점검중입니다 죄송합니다', 12),
('불량회원제제내역', '허위매물로 신고된 유저의 제제내역입니다', 12);


-- 12. 문의 (inquiry)
INSERT INTO inquiry (inquiry_title, inquiry_content, user_id) VALUES
('입찰 오류 문의', '입찰이 안돼요', 1),
('포인트 환불 문의', '환불은 어떻게 하나요?',2),
('배송 문의', '배송은 어떻게 진행되나요?',2),
('포인트 문의', '제 포인트는 어떻게 관리 되는건가요?',2),
('입찰 문의', '1분남기고 입찰을 하면 어떻게 되나요',1),
('이벤트 문의', '친구 추천을 하고싶은데 어찌하나요',2),
('기타 문의', '관리자 1:1 상담은 못하는건가요?',2);


-- 13. 신고 (report)
INSERT INTO report ( report_content, category_id, auction_id, reporter_id) VALUES
( '허위 상품 같아요', 5, 1, 2),
( '사기 의심됩니다', 5, 2, 3),
( '상품 부서졌어요', 5, 3, 1),
( '상품이 불량입니다', 14, 6, 1),
( '사기 상품입니다', 14, 7, 1),
( '사기꾼 입니다', 14, 9, 1),
( '상품 부서졌어요', 5, 5, 2),
( '모든게 거짓이에요', 14, 8, 2);


-- 14. 배송 (delivery)
INSERT INTO delivery (delivery_address, delivery_no, delivery_status, send_user_id, receiver_user_id, auction_id) VALUES
('서울 강남구 101동 202호', '123456789', 'S', 1, 2, 1),
('부산 해운대구 303동 404호', '987654321', 'S', 2, 3, 2),
('', '', '', 2, 3, 2),
('', '', '', 1, 4, 3),
('부산 해운대구 앞바다', '', 'E', 6, 7, 6),
('부산 해운대구 앞바다', '', 'E', 6, 8, 7),
('부산 해운대구 앞바다', '1243234445', 'I', 6, 4, 9),
('경기도 뉴욕시 쉑쉑버거1층', '3567534244', 'I', 2, 7, 5);


-- 15. 파일 (file)
INSERT INTO file (auction_id, file_path, file_name, file_type, review_id) VALUES
(1, '/home/charly/image/', 'iphone14', 'jpg', 1),
(2, '/home/charly/image/', 'galaxy25', 'jpg',2 ),
(7, '/home/charly/image/', 'shoes', 'jpg',4 ),
(9, '/home/charly/image/', 'tree branche', 'jpg',5 );


-- 16. 포인트 로그 (point_log)
INSERT INTO point_log(trade_type,trade_amount,trade_explanation,bid_id,user_id,point_amount) VALUES
('U',805000, '입찰 시 포인트 차감', 1, 2, 100000),
('T',500000, '최종 낙찰 수령완료 포인트이전', 2, 3, 600000),
('I',950000, '포인트가 충전 되었습니다',null,1,950000),
('I', 1000000, '포인트 충전', NULL, 1, 1000000),
('U', 805000, '입찰 시 포인트 차감', 1, 2, 195000),
('T', 500000, '최종 낙찰 수령완료 포인트 이전', 2, 3, 600000),
('C', 200000, '포인트 환불', NULL, 2, 786000),
('R', 100000, '포인트 반환', NULL, 1, 295000),
('U', 950000, '입찰 시 포인트 차감', 3, 3, 50000),
('I', 300000, '포인트 충전', NULL, 4, 300000),
('T', 450000, '최종 낙찰 수령완료 포인트 이전', 4, 5, 450000),
('C', 150000, '포인트 환불', NULL, 6, 270000),
('R', 50000, '포인트 반환', NULL, 7, 880000);


-- 17. 회원 로그 (user_log)
INSERT INTO user_log (user_id, user_log_content, column_name) VALUES
(1, '닉네임 변경: 철수짱 → 슈퍼철수', 'user_nickname'),
(2, '전화번호 변경: 010-1111-2222 → 010-3333-4444', 'user_phone'),
(1, '비밀번호 변경 처리', 'user_password'),
(3, '이메일 수정: old@example.com → new@example.com', 'user_email'),
(2, '상태 변경: Y → B(비활성)', 'user_status'),
(1, '닉네임 변경: 길동이 → 홍길동짱', 'user_nickname'),
(2, '전화번호 변경: 010-2025-0202 → 010-2222-3333', 'user_phone'),
(3, '비밀번호 변경 처리', 'user_password'),
(4, '이메일 수정: user04@test.com → new04@test.com', 'user_email'),
(5, '상태 변경: Y → N(비활성)', 'user_status'),
(6, '닉네임 변경: 욱이형 → 민욱형', 'user_nickname'),
(7, '전화번호 변경: 010-6675-3544 → 010-6675-5555', 'user_phone'),
(8, '비밀번호 변경 처리', 'user_password'),
(9, '이메일 수정: user09@test.com → user09_new@test.com', 'user_email'),
(10, '상태 변경: Y → B(정지)', 'user_status');

-- 18. 알람 박스 (alaram_box)
INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id, alarm_content)

SELECT
    'N', a.user_id, c.alarm_id, b.auction_id,
    CONCAT(a.user_name, ' 님! ', b.auction_title, ' 의 ', c.alarm_content)
FROM user a
JOIN auction_item b ON b.auction_id = 2
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
