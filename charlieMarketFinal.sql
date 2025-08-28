CREATE TABLE grade (
	grade_id INT NOT NULL AUTO_INCREMENT COMMENT '회원코드',
	grade_name VARCHAR(5) NOT NULL COMMENT '회원별 등급(B,S,G,P)',
	grade_fee_rate DECIMAL(10,2) NOT NULL COMMENT '등급별 수수료율(10, 7, 5, 3)',
	grade_standard INT NULL COMMENT 'S (20), G (50), P (100)',
	PRIMARY KEY(grade_id)
);


CREATE TABLE user (
	user_id INT NOT NULL AUTO_INCREMENT,
	user_role ENUM ('USER','ADMIN') NOT NULL DEFAULT 'USER' COMMENT '관리자 여부',
	id VARCHAR(20) NOT NULL COMMENT '회원 아이디',
	user_password VARCHAR(999) NOT NULL COMMENT '회원 PASSWORD',
	user_name VARCHAR(20) NOT NULL COMMENT '회원 이름',
	user_phone INT NOT NULL COMMENT '회원 전화번호',
	user_email VARCHAR(50) NOT NULL COMMENT '회원 이메일',
	user_status CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '활성, 비활성, 탈퇴(Y, B, N)',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '계정 생성 시간',
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '계정정보 수정시간',
	grade_id INT NOT NULL COMMENT '계정 등급코드',
	user_balance INT NOT NULL DEFAULT 0 COMMENT '계정잔고',
	trade_count INT NOT NULL DEFAULT 0 COMMENT '회원별로 거래를 몇번했는지 책정',
	user_nickname VARCHAR(20) NOT NULL COMMENT '회원 닉네임',
	PRIMARY KEY(user_id),
 	FOREIGN KEY(grade_id) REFERENCES grade(grade_id)
);



CREATE TABLE notice (
	notice_id INT NOT NULL AUTO_INCREMENT,
	notice_title VARCHAR(50) NOT NULL COMMENT '공지사항 제목',
	notice_content VARCHAR(999) NOT NULL COMMENT '공지사항 내용',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '게시시간',
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수정시간',
	notice_status CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '저장상태 (Y, N)',
	user_id INT NOT NULL COMMENT '관리자회원코드',
	PRIMARY KEY(notice_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id)
);


CREATE TABLE user_history (
	user_log_id INT NOT NULL AUTO_INCREMENT COMMENT '로그 ID',
	user_id INT NOT NULL COMMENT '회원id',
	user_log_content VARCHAR(999) NULL COMMENT '상세내용(전, 후)',
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수정 시간',
	column_name VARCHAR(999) NULL COMMENT '수정 유형(컬럼명)',
	PRIMARY KEY(user_log_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id)
);


CREATE TABLE account (
	account_id INT NOT NULL AUTO_INCREMENT ,
	bank_name VARCHAR(10) NOT NULL COMMENT '은행명',
	account_no INT NOT NULL COMMENT '계좌번호',
	bank_owner VARCHAR(20) NOT NULL COMMENT '예금주명',
	user_id INT NOT NULL COMMENT '회원코드',
	main_status CHAR(1) NULL COMMENT '대표계좌 (Y)',
	PRIMARY KEY(account_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id)
);



CREATE TABLE payment_log (
	payment_log_id INT NOT NULL AUTO_INCREMENT COMMENT '결제이력코드',
	payment_type CHAR(1) NOT NULL COMMENT '충전/환불(C,R)',
	account_id INT NOT NULL COMMENT '계좌코드',
	user_id INT NOT NULL COMMENT 'auto increment',
	payment_amount INT NOT NULL COMMENT '결제금액',
	conversion_amount INT NOT NULL COMMENT '포인트전환금액(수수료 적용)',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '결제시간',
	grade_name VARCHAR(5) NOT NULL COMMENT '회원 등급명',
	point_amount INT NOT NULL COMMENT '현재 포인트',
	PRIMARY KEY(payment_log_id),
	FOREIGN KEY(account_id) REFERENCES user(user_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id)
);



CREATE TABLE inquiry (
	inquiry_id INT NOT NULL AUTO_INCREMENT COMMENT '문의코드',
	inquiry_title VARCHAR(50) NOT NULL COMMENT '문의제목',
	inquiry_content VARCHAR(999) NOT NULL COMMENT '문의내용',
	inquiry_status CHAR(1) NOT NULL DEFAULT 'N' COMMENT '문의상태 처리여부 (Y, N)',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '문의시간',
	finished_at TIMESTAMP NULL COMMENT '문의 처리 완료 시간',
	inquiry_answer VARCHAR(999) NULL COMMENT '답변 내용',
	user_id INT NOT NULL COMMENT '작성자 회원코드',
	admin_id INT NOT NULL COMMENT '문의 답변 작성자',
	PRIMARY KEY(inquiry_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id),
	FOREIGN KEY(admin_id) REFERENCES user(user_id)
);



CREATE TABLE category (
	category_id INT NOT NULL AUTO_INCREMENT COMMENT 'auto increment',
	category_type CHAR(1) NOT NULL COMMENT '물품/알림/신고 (I,A,R)',
	category_name VARCHAR(50) NOT NULL COMMENT '카테고리 이름을 지정해놓음',
	category_status CHAR(1) NOT NULL DEFAULT 'N' COMMENT '카테고리사용여부(Y,N)',
	PRIMARY KEY(category_id)
);



CREATE TABLE auction_item (
	auction_id INT NOT NULL auto_increment COMMENT 'auto increment',
	user_id INT NOT NULL COMMENT '경매 물품 판매자',
	auction_title VARCHAR(100) NOT NULL COMMENT '경매물품에 대한 제목',
	auction_content VARCHAR(2000) NOT NULL COMMENT '경매물품에 대한 설명글',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '경매 물품을 등록한 시간',
	updated_at TIMESTAMP NULL COMMENT '경매 물품에 대한 정보를 수정한 시간',
	starting_price INT NOT NULL COMMENT '판매자가 지정한 최소 입찰 가격',
	current_price INT NULL COMMENT '현재까지 나온 최고 입찰 가격',
	bid_unit INT NOT NULL COMMENT '최소 100원 단위 이상 입찰 가능',
	bid_status CHAR(1) NULL COMMENT '입찰/낙찰 여부 낙찰시(Y)',
	auction_start_time TIMESTAMP NULL COMMENT '경매 시작 시간(물품등록 30분 후)',
	auction_end_time TIMESTAMP NULL COMMENT '경매 종료 시간(10분씩 연장)',
	seller_address VARCHAR(99) NOT NULL COMMENT '판매자의 시/군/구 주소',
	category_id INT NOT NULL COMMENT '물품 카테고리',
	PRIMARY KEY (auction_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id),
	FOREIGN KEY(category_id) REFERENCES category(category_id)
);



CREATE TABLE alarm_template (
	alarm_id INT NOT NULL AUTO_INCREMENT COMMENT 'auto increment',
	alarm_temp VARCHAR(999) NULL COMMENT '알림 내용 틀',
	alarm_temp_status CHAR(1) NULL DEFAULT 'Y' COMMENT '알림 틀을 사용할지 말지',
	category_id INT NOT NULL COMMENT '어떤 카테고리의 알림인지',
	PRIMARY KEY(alarm_id),
	FOREIGN KEY(category_id) REFERENCES category(category_id)
);


CREATE TABLE alarm_box (
	alarm_box_id INT NOT NULL AUTO_INCREMENT COMMENT 'auto increment',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '알림 발송 시간',
	alarm_check CHAR(1) NULL COMMENT '알림을 확인 여부 (Y : 확인)',
	user_id INT NOT NULL COMMENT '알림을 받는 회원',
	alarm_id INT NOT NULL COMMENT '알림 유형',
	auction_id INT NOT NULL COMMENT '물품 id',
	PRIMARY KEY(alarm_box_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id),
	FOREIGN KEY(alarm_id) REFERENCES alarm_template(alarm_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id)
);



CREATE TABLE report (
	report_id INT NOT NULL AUTO_INCREMENT COMMENT 'auto increment',
	report_at TIMESTAMP NOT NULL COMMENT '신고한 날짜',
	report_content VARCHAR(999) NOT NULL COMMENT '신고한 내용',
	report_status CHAR(1) NOT NULL COMMENT '신고 조치 완료 시(Y)',
	report_action VARCHAR(999) NULL COMMENT '신고 조치한 내용',
	category_id INT NOT NULL COMMENT '어떤 유형의 신고인지',
	auction_id INT NOT NULL COMMENT '신고할 물품 코드', -- category fk
	reporter_id INT NOT NULL COMMENT '신고를 하는 사람', -- user fk
	handler_id INT NOT NULL COMMENT '신고를 처리하는 사람', -- user fk
	PRIMARY KEY (report_id),
	FOREIGN KEY(category_id) REFERENCES category(category_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id),
	FOREIGN KEY(reporter_id) REFERENCES user(user_id),
	FOREIGN KEY(handler_id) REFERENCES user(user_id)
);




CREATE TABLE delivery (
	delivery_id INT NOT NULL AUTO_INCREMENT,
	delivery_address VARCHAR(100) NOT NULL COMMENT '낙찰자가 입력',
	delivery_no INT NOT NULL COMMENT '판매자가 등록한 운송장번호',
	delivery_status CHAR(1) NOT NULL COMMENT '베송보냄/반송/배송완료 확인',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '운송장번호를 입력한시간',
	finished_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '배송을 수령한 시간',
	send_user_id INT NOT NULL COMMENT '판매자',
	reciver_user_id INT NOT NULL COMMENT '낙찰자',
	auction_id INT NOT NULL COMMENT '경매 물품',
	registered_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성된 시간(수령지 입력 시간)',
	PRIMARY KEY(delivery_id),
	FOREIGN KEY(send_user_id) REFERENCES user(user_id),
	FOREIGN KEY(reciver_user_id) REFERENCES user(user_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id)
);



CREATE TABLE auction_bid (
	bid_id INT NOT NULL AUTO_INCREMENT COMMENT 'auto increment',
	bid_amount INT NOT NULL COMMENT '입찰자가 제시한 입찰가',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '입찰가를 제시한 시간',
	success_status CHAR(1) NULL COMMENT 'Y(최종 낙찰 여부)',
	auction_id INT NOT NULL COMMENT '입찰한 물품 코드',
	user_id INT NOT NULL COMMENT '입찰자 코드',
	PRIMARY KEY (bid_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id)
);




CREATE TABLE point_log (
	point_log_id INT NOT NULL AUTO_INCREMENT,
	trade_type CHAR(1) NOT NULL COMMENT '포인트 사용/반환/이전',
	trade_amount INT NOT NULL COMMENT '거래한 포인트 금액',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '거래한 일시',
	trade_explanation VARCHAR(999) NULL COMMENT '충전, 환불, 보관, 이전에 대한 세부 내용',
	bid_id INT NOT NULL COMMENT '입찰한 내용',
	user_id INT NOT NULL COMMENT '포인트 거래가 발생하는 회원',
	point_amount INT NOT NULL COMMENT '현재 포인트',
	PRIMARY KEY(point_log_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id),
	FOREIGN KEY(bid_id) REFERENCES auction_bid(bid_id)
);


CREATE TABLE review (
	review_id INT NOT NULL AUTO_INCREMENT,
	review_star INT NOT NULL COMMENT '평가 별점 점수 (1~5)',
	review_content VARCHAR(999) NOT NULL COMMENT '후기 내용',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '후기 등록 시간',
	updated_at TIMESTAMP NULL COMMENT '후기 수정 시간',
	review_status CHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'Y : 활성화',
	reviewer_id INT NOT NULL COMMENT '후기 작성자',
	reviewee_id INT NOT NULL COMMENT '후기가 입력되는 대상',
	auction_id INT NOT NULL COMMENT '물품코드',
	PRIMARY KEY(review_id),
	FOREIGN KEY(reviewer_id) REFERENCES user(user_id),
	FOREIGN KEY(reviewee_id) REFERENCES user(user_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id)
);


CREATE TABLE file (
	file_id INT NOT NULL AUTO_INCREMENT,
	auction_id INT NOT NULL COMMENT '경매 물품코드',
	file_address VARCHAR(999) NULL COMMENT '파일 경로',
	file_name VARCHAR(255) NULL COMMENT '파일 이름',
	file_type VARCHAR(10) NULL COMMENT '확장자 종류 (JPG,PNG,PDF등)',
	review_id INT NOT NULL COMMENT '후기',
	inquiry_id INT NOT NULL COMMENT '문의',
	notice_id INT NOT NULL COMMENT '공지사항',
	PRIMARY KEY(file_id),
	FOREIGN KEY(review_id) REFERENCES review(review_id),
	FOREIGN KEY(inquiry_id) REFERENCES inquiry(inquiry_id),
	FOREIGN KEY(notice_id) REFERENCES notice(notice_id)
);


CREATE TABLE favorite (
	user_id INT NOT NULL COMMENT '회원',
	auction_id INT NOT NULL COMMENT '즐겨찾기한 물품내용',
	PRIMARY KEY (user_id,auction_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id),
	FOREIGN KEY(auction_id) REFERENCES auction_item(auction_id)
);


