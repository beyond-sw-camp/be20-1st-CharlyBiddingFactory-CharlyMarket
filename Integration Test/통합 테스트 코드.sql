
-- 9. 알림 (먼저 등록 후 시나리오 실행)
-- 알림 등록을 위한 카테고리 우선 실행

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

-- 알람 템플릿 등록
INSERT INTO alarm_template (alarm_content, alarm_status, category_id)
SELECT '경매가 시작되었습니다.', 'Y', 15
WHERE NOT EXISTS (
  SELECT 1 FROM alarm_template WHERE category_id=15 AND alarm_status='Y' AND alarm_content LIKE '%경매가 시작%'
);

INSERT INTO alarm_template (alarm_content, alarm_status, category_id)
SELECT '상위 입찰이 등록되었습니다.', 'Y', 15
WHERE NOT EXISTS (
  SELECT 1 FROM alarm_template WHERE category_id=15 AND alarm_status='Y' AND alarm_content LIKE '%상위 입찰%'
);

INSERT INTO alarm_template (alarm_content, alarm_status, category_id)
SELECT '낙찰되었습니다.', 'Y', 15
WHERE NOT EXISTS (
  SELECT 1 FROM alarm_template WHERE category_id=15 AND alarm_status='Y' AND alarm_content LIKE '%낙찰%'
);

-- 푸시 알람 발송 프로시저
DROP PROCEDURE IF EXISTS send_alarm_kw;
DELIMITER //
CREATE PROCEDURE send_alarm_kw(
    IN p_user_id INT,
    IN p_auction_id INT,        -- 회원(14)일 때 NULL/0 가능(아래 보정)
    IN p_category_id INT,       -- 14=회원, 15=경매, 16=배송
    IN p_keyword VARCHAR(100),  -- 템플릿 키워드(예: 회원가입/비밀번호/경매가 시작/새로운 입찰/낙찰/배송/완료/운송장 번호)
    IN p_extra VARCHAR(200)     -- 추가 설명(옵션)
)
BEGIN
  main: BEGIN
    DECLARE v_alarm_id   INT;
    DECLARE v_template   VARCHAR(999);
    DECLARE v_msg        VARCHAR(1000);
    DECLARE v_auction_id INT;

   -- 회원(14) 보정: alarm_box.auction_id NOT NULL 대응 alarm box 테이블auction_id 행 널 필요
    IF (p_category_id = 14) AND (p_auction_id IS NULL OR p_auction_id = 0) THEN
        SELECT MIN(auction_id) INTO v_auction_id FROM auction_item;
        IF v_auction_id IS NULL THEN LEAVE main; END IF;
    ELSE
        SET v_auction_id = p_auction_id;
    END IF;

    -- 2) 템플릿 선택: 카테고리+키워드 우선 → 없으면 최신 활성 
    SET v_alarm_id = NULL;
    SELECT alarm_id, alarm_content
      INTO v_alarm_id, v_template
    FROM alarm_template
    WHERE category_id = p_category_id
      AND alarm_status = 'Y'
      AND alarm_content LIKE CONCAT('%', p_keyword, '%')
    ORDER BY alarm_id DESC
    LIMIT 1;

    IF v_alarm_id IS NULL THEN
      SELECT alarm_id, alarm_content
        INTO v_alarm_id, v_template
      FROM alarm_template
      WHERE category_id = p_category_id
        AND alarm_status = 'Y'
      ORDER BY alarm_id DESC
      LIMIT 1;
    END IF;

    IF v_alarm_id IS NULL THEN LEAVE main; END IF;

    -- 3) 최종 문구 조립 
    SELECT
      CASE p_category_id
        WHEN 14 THEN CONCAT('[회원알림] ', u.user_name, '님 ',  v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        WHEN 15 THEN CONCAT('[경매알림] ', u.user_name, '님 [', COALESCE(ai.auction_title,''), '] ', v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        WHEN 16 THEN CONCAT('[배송알림] ', u.user_name, '님 [', COALESCE(ai.auction_title,''), '] ', v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        ELSE v_template
      END
    INTO v_msg
    FROM `user` u
    LEFT JOIN auction_item ai ON ai.auction_id = v_auction_id
    WHERE u.user_id = p_user_id;

    -- 4) alarm_box 저장 
    INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id, alarm_content)
    VALUES ('N', p_user_id, v_alarm_id, v_auction_id, v_msg);
  END main;
END //
DELIMITER ;



-- 경매 관련 트리거
-- 경매 시작
DROP TRIGGER IF EXISTS trg_bid_first_insert;
DELIMITER //
CREATE TRIGGER trg_bid_first_insert
AFTER UPDATE ON auction_item
FOR EACH ROW
BEGIN
	IF NEW.bid_status='B' THEN
  	CALL send_alarm_kw(NEW.user_id, NEW.auction_id, 15, '경매가 시작', NULL);
  END IF;
END //
DELIMITER ;



-- 상위 입찰
-- 새로운 입찰자 발생 시 이전 입찰자에게 알림 발송
DROP TRIGGER IF EXISTS trg_bid_up_insert;
DELIMITER //
CREATE TRIGGER trg_bid_up_insert
AFTER INSERT ON auction_bid
FOR EACH ROW
BEGIN
    DECLARE old_user_id INT;

    -- 방금 들어온 사람 제외하고, 같은 물품에서 가장 높은 입찰자 찾기
    SELECT user_id
      INTO old_user_id
    FROM auction_bid
    WHERE auction_id = NEW.auction_id
      AND bid_id <> NEW.bid_id
    ORDER BY bid_amount DESC, created_at DESC
    LIMIT 1;

    -- 이전 최고 입찰자가 존재한다면 알림 전송
    IF old_user_id IS NOT NULL THEN
        CALL send_alarm_kw(old_user_id, NEW.auction_id, 15, '상위 입찰', NULL);
    END IF;
END //
DELIMITER ;



-- 낙찰(success_status = 'Y')
-- 낙찰 발생 시 판매자와 최종 입찰자에게 알림 발송
DROP TRIGGER IF EXISTS trg_bid_after_update;
DELIMITER //
CREATE TRIGGER trg_bid_after_update
AFTER UPDATE ON auction_bid
FOR EACH ROW
BEGIN
	DECLARE auction_user_id INT;

  IF NEW.success_status = 'Y' AND (OLD.success_status IS NULL OR OLD.success_status <> 'Y') THEN
  
  	SELECT ai.user_id INTO auction_user_id
	  FROM auction_bid ab
	  JOIN auction_item ai ON ab.auction_id=ai.auction_id
	 WHERE ab.auction_id=NEW.auction_id
	 LIMIT 1; 
    CALL send_alarm_kw(NEW.user_id, NEW.auction_id, 15, '낙찰', NULL); 
   CALL send_alarm_kw(auction_user_id, NEW.auction_id, 15, '낙찰', NULL);
  END IF;
END //
DELIMITER ;

-- -----------------------------------------------------------------------------------------------
-- 1. 회원 가입 & 등급
-- 1-1. 등급 (grade) 생성
INSERT INTO grade (grade_name, grade_fee_rate, grade_standard) VALUES
('B', 10.00, 0),
('S', 7.00, 20),
('G', 5.00, 50),
('P', 3.00, 100);

-- 1-* 회원등급 트리거
DELIMITER //

CREATE TRIGGER update_user_grade
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    -- trade_count 값에 따라 grade_id 자동 변경
    IF NEW.trade_count >= 100 THEN
        SET NEW.grade_id = 4; -- P
    ELSEIF NEW.trade_count >= 50 THEN
        SET NEW.grade_id = 3; -- G
    ELSEIF NEW.trade_count >= 20 THEN
        SET NEW.grade_id = 2; -- S
    ELSE
        SET NEW.grade_id = 1; -- B
    END IF;
END //

DELIMITER ;

-- 1-2. 회원가입
INSERT INTO user (user_role, id, user_password, user_name, user_phone, user_email, grade_id, user_nickname) VALUES
('USER', 'user01', 'pw01', '홍길동', '01012341234', 'user01@test.com', 1, '길동이'),
('USER', 'user02', 'pw02', '김영희', '01056785678', 'user02@test.com', 2, '영희짱'),
('ADMIN', 'admin01', 'adminpw01', '관리자', '01099999999', 'admin1@test.com', 4, '운영자'),
('USER', 'user03', 'pw03', '한철수', '01093279327', 'user03@test.com', 3, '난철수')
;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 2. 계좌등록 & 충전
-- 2-1. 회원 계좌 등록
INSERT INTO account (bank_name, account_no, bank_owner, user_id)
VALUES ('농협은행', '111-222-333', '홍길동', 1),
('신한은행', '444-555-666', '김영희', 2),
('우리은행', '777-888-999', '한철수', 4);

-- 2.2 포인트 충전

DELIMITER //

CREATE PROCEDURE charge_point2(
    IN p_user_id INT,
    IN p_account_id INT, -- 회원이 자신의 계좌를 선택하는 상황
    IN p_payment_amount INT
)
BEGIN
    DECLARE v_grade_rate DECIMAL(10,2); -- 수수료율
    DECLARE v_conversion_amount INT; -- 수수료 뺀 전환 금액
    DECLARE v_grade_name VARCHAR(5); -- 등급
    DECLARE v_point_amount INT; -- 가지고 있는 포인트 금액
    DECLARE v_admin_id INT; -- 관리자 계좌

    -- 회원의 등급과 수수료율 가져오기
    SELECT g.grade_fee_rate, g.grade_name 
    INTO v_grade_rate, v_grade_name
    FROM user u
    JOIN grade g ON u.grade_id = g.grade_id
    WHERE u.user_id = p_user_id;

    -- 전환 금액 계산
    SET v_conversion_amount = FLOOR(p_payment_amount * (100 - v_grade_rate) / 100);

    -- 운영자 계정 가져오기
    SELECT user_id INTO v_admin_id
    FROM user
    WHERE user_role = 'ADMIN'
    LIMIT 1;

    -- 회원 잔고 업데이트
    UPDATE user
    SET user_balance = user_balance + v_conversion_amount
    WHERE user_id = p_user_id;

    -- 관리자 잔고 업데이트 (수수료)
    UPDATE user
    SET user_balance = user_balance + (p_payment_amount - v_conversion_amount)
    WHERE user_id = v_admin_id;

    -- 회원의 최신 포인트 확인
    SELECT user_balance INTO v_point_amount
    FROM user
    WHERE user_id = p_user_id;

    -- 결제 로그 기록
    INSERT INTO payment_log (payment_type, account_id, user_id, payment_amount, conversion_amount, grade_name, point_amount)
    VALUES ('C', p_account_id, p_user_id, p_payment_amount, v_conversion_amount, v_grade_name, v_point_amount);
    
    -- 포인트 로그 기록
    INSERT INTO point_log (trade_type, trade_amount, created_at, trade_explanation, user_id, point_amount)
    VALUES ('I', p_payment_amount, NOW(), "충전했습니다", p_user_id, v_conversion_amount);

END //

DELIMITER ;

-- 홍길동 100000충전
CALL charge_point2(1,1,100000);
-- 김영희  80000충전
CALL charge_point2(2,2,80000);
-- 한철수 1000000충전
CALL charge_point2(4,3,1000000);

SELECT * FROM point_log;
SELECT * FROM payment_log;
SELECT * FROM user;

-- -----------------------------------------------------------------------------------------------------
-- 3. 공지사항 & 문의
-- 3-1. 문의사항 등록
SELECT * FROM inquiry;

INSERT INTO inquiry(inquiry_title,inquiry_content,user_id)VALUES 
('배송 관련 문의드립니다.','배송이 너무 오래걸려 문의 드립니다. 도착예정일을 알 수 있을까요',1);
INSERT INTO file(inquiry_id,file_path,file_name, file_type)VALUES
(1,'/home/charly/ima/iphone', 'iphone','jpg' ); 

INSERT INTO inquiry(inquiry_title,inquiry_content,user_id)VALUES 
('포인트 관련 문의 드립니다.','포인트가 제대로 충전이 안됩니다. 해결 부탁드려요',2);
SELECT * FROM inquiry;

-- 관리자 문의 답변

DELIMITER //
CREATE PROCEDURE update_inquiry_answer(
    IN check_user_id INT,    -- 사용자의 ID
    IN check_inquiry_id INT   -- 수정할 공지사항의 ID
)
BEGIN
    DECLARE check_inquiry_status CHAR(1);
    DECLARE check_user_role VARCHAR(15);

   SELECT user_role INTO check_user_role
   	FROM user
   WHERE user_id=check_user_id;
   
   SELECT inquiry_status INTO check_inquiry_status
   	FROM inquiry
   WHERE inquiry_id=check_inquiry_id;
   
	IF check_inquiry_status='N' AND check_user_role='ADMIN' THEN
		UPDATE inquiry
		 SET inquiry_status='Y',
		 	  finished_at=NOW(),
			  inquiry_answer='빠른 시일 내 해결하겠습니다.',
			  admin_id=check_user_id
		 WHERE inquiry_id =check_inquiry_id;	
		 SELECT '답변이 완료되었습니다.';	  
 	ELSEIF check_inquiry_status='Y' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '답변이 완료된 문의글 입니다.';
   ELSEIF check_user_role!='ADMIN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '권한이 없습니다.';
	 END IF;
	END//
DELIMITER ;

SELECT * FROM user;
SELECT * FROM inquiry;
CALL UPDATE_inquiry_answer(3,1);
SELECT * FROM inquiry;



-- 3-2. 공지
-- 공지사항 등록 (관리자가 작성:성공)
INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('경매 물품 가격 오류 공지','경매물품 가격이 제대로 표시되지 않는 오류가 발생 했습니다.',3);

INSERT INTO file (notice_id, file_path, file_name, file_type) VALUES
(1, '/home/charly/ima/iphone', 'iphone', 'jpg'); 

INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('경매 입찰 오류 공지','경매물품 입찰이 제대로 되지 않는 오류가 발생 했습니다.',3);		
INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('등급 오류 공지','회원 등급이 비정상 적용 되는 오류가 발생 했습니다.',3);		

SELECT * FROM notice;


-- 공지사항 수정(공지사항 id=1)
UPDATE notice n
      LEFT JOIN file f ON n.notice_id = f.notice_id
   SET
      n.notice_title = '공지사항 문제 발생',
      n.notice_content = ' 공지사항에 접근하지 말아주시길 바랍니다 .',
      n.updated_at = NOW(),
      f.file_path = '/do',
      f.file_name = 'err',
      f.file_type = 'jpg'
   WHERE 
      n.notice_id = 2;



SELECT * FROM notice;


-- 공지사항 삭제(공지사항 id=1)
DELIMITER //

CREATE PROCEDURE delete_notice_check(
    IN check_notice_id INT   -- 수정할 공지사항의 ID
)
BEGIN
    DECLARE check_notice_status CHAR(1);
    
    --  공지사항이 활성화 상태인지 확인
   SELECT notice_status
	   INTO check_notice_status
		FROM notice
	WHERE notice_id = check_notice_id;

    IF check_notice_status ='Y' THEN
        UPDATE notice n
        SET
            n.notice_status = 'N'
        WHERE 
            n.notice_id = check_notice_id;
        SELECT '공지사항이 삭제되었습니다.' AS result;
        -- 유저가 admin이 아닐 떄
    ELSEIF check_notice_status != 'Y' THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 제거 된 공지사항입니다.';
    END IF;

END//

DELIMITER ;

CALL delete_notice_check (2);
SELECT * FROM notice;

-- -----------------------------------------------------------
-- 4. 경매등록
-- 4-1. 카테고리 생성
-- 위에서 실행 시킴

-- 4-2. 경매 등록
SELECT * FROM auction_item;
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
INSERT INTO favorite (user_id, auction_id) VALUES (4,1);
SELECT * FROM favorite;


-- ---------------------------------------------------------------------
-- 5. 입찰,& 낙찰

-- 5-1. 입찰

-- 경매 물품 첫 입찰 프로시저
DELIMITER //

CREATE PROCEDURE sp_first_bid(
    IN p_auction_id INT,
    IN p_user_id    INT,
    IN p_bid_amount INT
)
BEGIN
    DECLARE v_now  DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end  DATETIME;
    DECLARE v_price INT;
    DECLARE v_bid_id INT;
    DECLARE v_point  INT;
	DECLARE v_balance INT;

    /* 에러 시 롤백하고 원본 에러 재던지기 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 1) 경매 잠금 & 검증 (최초 입찰: 시작가 기준) */
    SELECT auction_end_time, starting_price
      INTO v_end, v_price
      FROM auction_item
     WHERE auction_id = p_auction_id
     FOR UPDATE;

    IF v_end IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 경매입니다.';
    END IF;
    IF v_now >= v_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 종료된 경매입니다.';
    END IF;
    IF p_bid_amount <> IFNULL(v_price, 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '입찰가와 시작가가 동일하지 않습니.';
    END IF;

    /* 2) 사용자 포인트 잠금 & 잔액 확인 */
    SELECT user_balance
      INTO v_point
      FROM `user`
     WHERE user_id = p_user_id
     FOR UPDATE;

    IF v_point IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 사용자입니다.';
    END IF;
    IF v_point < p_bid_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '포인트가 부족합니다.';
    END IF;

    /* 3) 입찰 로그 */
    INSERT INTO auction_bid (auction_id, user_id, bid_amount)
    VALUES (p_auction_id, p_user_id, p_bid_amount);

    SET v_bid_id = LAST_INSERT_ID();

    /* 4) 포인트 보관(가용 ↓, 보관 ↑) */
	UPDATE `user`
   		SET user_balance = COALESCE(user_balance, 0) - p_bid_amount,
 	        stored_point = COALESCE(stored_point, 0) + p_bid_amount
	  WHERE user_id = p_user_id;

    SELECT user_balance 
      INTO v_balance
      FROM `user`
     WHERE user_id = p_user_id;

    /* 5) 포인트 이력 (타임스탬프는 DEFAULT CURRENT_TIMESTAMP 가정) */
    INSERT INTO point_log (
        trade_type, trade_amount, trade_explanation,
        bid_id, user_id, point_amount
    ) VALUES (
        'B',
        p_bid_amount,
        '입찰 포인트 보관',
        v_bid_id,
        p_user_id,
        v_balance
    );

    /* 6) 경매 상태/현재가 갱신 (최초 입찰) */
    UPDATE auction_item
       SET current_price = p_bid_amount,
           bid_status    = 'B'
     WHERE auction_id = p_auction_id;

    /* 7) 종료 10분 이내면 10분 연장 */
    IF TIMESTAMPDIFF(MINUTE, v_now, v_end) <= 10 THEN
        UPDATE auction_item
           SET auction_end_time = DATE_ADD(auction_end_time, INTERVAL 10 MINUTE)
         WHERE auction_id = p_auction_id;
    END IF;

    COMMIT;
END;
//
DELIMITER ;

-- 영희 50000원 시작 입찰
CALL sp_first_bid(1,2,50000);

-- 경매 물품 상위 입찰 프로시저
DELIMITER //

CREATE PROCEDURE sp_top_bid(
    IN p_auction_id INT,
    IN p_user_id    INT,
    IN p_bid_amount INT
)
BEGIN
    DECLARE v_now       DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end       DATETIME;
    DECLARE v_price     INT;      
    DECLARE v_bid_id    INT;
    DECLARE v_point     INT;     
    DECLARE v_prev_uid  INT;    
    DECLARE v_prev_bid  INT;   
    DECLARE v_prev_bid_id INT;
    DECLARE v_cnt         INT;
	DECLARE v_new_balance INT;
	DECLARE v_balance     INT;

    /* 에러 시 롤백하고 원본 에러 재던지기 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 0) 최초 입찰 방지(이 프로시저는 '상위 입찰' 전용) */
    SELECT COUNT(*) INTO v_cnt
      FROM auction_bid
     WHERE auction_id = p_auction_id;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '최초 입찰은 sp_first_bid를 사용하세요.';
    END IF;
    
    /* 1) 경매행 잠금 & 검증 */
    SELECT auction_end_time, current_price
      INTO v_end, v_price
      FROM auction_item
     WHERE auction_id = p_auction_id
     FOR UPDATE;
    
    IF v_end IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 경매입니다.';
    END IF;
    IF v_now >= v_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 종료된 경매입니다.';
    END IF;
    IF p_bid_amount <= IFNULL(v_price, 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '입찰가는 현재가보다 커야 합니다.';
    END IF;
        
    /* 2) 기존 최고입찰자/최고가 조회 (가장 높은 금액, 같으면 최근 bid 우선) */
    SELECT b.user_id, b.bid_amount, b.bid_id
      INTO v_prev_uid, v_prev_bid, v_prev_bid_id
      FROM auction_bid b
     WHERE b.auction_id = p_auction_id
     ORDER BY b.bid_amount DESC, b.bid_id DESC
     LIMIT 1;

    /* 3) 신규 입찰자 가용 포인트 잠금 & 검증 */
    SELECT user_balance
      INTO v_point
      FROM `user`
     WHERE user_id = p_user_id
     FOR UPDATE;
    
    IF v_point IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 사용자입니다.';
    END IF;    
    
    /* 동일인이 또 상향 입찰하는 경우: 추가 홀드가 필요 (증가분만) */
    IF v_prev_uid IS NOT NULL AND v_prev_uid = p_user_id THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 입찰중인 상품입니다.';
    ELSE
        /* 서로 다른 사용자가 상위 입찰하는 일반 케이스 */

        /* 3-1) 신규 입찰자 가용 검증 */
        IF v_point < p_bid_amount THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '포인트가 부족합니다.';
        END IF;

        /* 3-2) 입찰 로그 */
        INSERT INTO auction_bid (auction_id, user_id, bid_amount)
        VALUES (p_auction_id, p_user_id, p_bid_amount);
        SET v_bid_id = LAST_INSERT_ID();

        /* 3-3) 기존 최고입찰자 포인트 반환 (있을 때만 처리) */
        IF v_prev_uid IS NOT NULL THEN
            /* 기존 최고자 행 잠금 */
            SELECT user_id FROM `user` WHERE user_id = v_prev_uid FOR UPDATE;

            UPDATE `user`
               SET user_balance = COALESCE(user_balance,0) + COALESCE(v_prev_bid,0),
                   stored_point = COALESCE(stored_point,0) - COALESCE(v_prev_bid,0)
             WHERE user_id = v_prev_uid;

            SELECT user_balance
              INTO v_balance
              FROM `user`
             WHERE user_id = v_prev_uid;
            
            /* 포인트 이력 (반환/보관해제) */
            INSERT INTO point_log (
                trade_type, trade_amount, trade_explanation,
                bid_id, user_id, point_amount
            ) VALUES (
                'R',
                v_prev_bid,
                '상위 입찰에 의한 포인트 반환',
                v_prev_bid_id,
                v_prev_uid,
                v_balance
            );
        END IF;

        /* 3-4) 신규 입찰자 포인트 보관 */
        UPDATE `user`
           SET user_balance = COALESCE(user_balance,0) - p_bid_amount,
               stored_point = COALESCE(stored_point,0) + p_bid_amount
         WHERE user_id = p_user_id;

        SELECT user_balance
          INTO v_new_balance
          FROM `user`
         WHERE user_id = p_user_id;
                
        /* 포인트 이력 (보관) */
        INSERT INTO point_log (
            trade_type, trade_amount, trade_explanation,
            bid_id, user_id, point_amount
        ) VALUES (
            'B',
            p_bid_amount,
            '상위 입찰 포인트 보관',
            v_bid_id,
            p_user_id,
            v_new_balance
        );
    END IF;

    /* 4) 경매 상태/현재가 갱신 */
    UPDATE auction_item
       SET current_price = p_bid_amount,
           bid_status    = 'B'
     WHERE auction_id = p_auction_id;

    /* 5) 종료 10분 이내면 10분 연장 */
    IF TIMESTAMPDIFF(MINUTE, v_now, v_end) <= 10 THEN
        UPDATE auction_item
           SET auction_end_time = DATE_ADD(auction_end_time, INTERVAL 10 MINUTE)
         WHERE auction_id = p_auction_id;
    END IF;

    COMMIT;
END;
//
DELIMITER ;

-- 한철수 60000원으로 입찰
CALL sp_top_bid(1,4,60000);

-- 5-2 낙찰
-- 낙찰 전 상태
SELECT * FROM auction_item;

SELECT * FROM auction_bid;

SELECT * FROM point_log;


-- 경매 물품 낙찰 프로시저
DELIMITER //

CREATE PROCEDURE sp_close_one_auction(IN p_auction_id INT)
proc: BEGIN
    DECLARE v_now DATETIME(6) DEFAULT NOW(6);
    DECLARE v_end DATETIME;
    DECLARE v_status CHAR(1);
    DECLARE v_win_uid INT;
    DECLARE v_win_bid INT;
    DECLARE v_win_bid_id INT;
	DECLARE v_seller_uid INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* 1) 대상 경매 선점: 마감 경매 선택 후 잠금 */
    UPDATE auction_item
       SET bid_status = 'F',
           updated_at = NOW()
     WHERE auction_id = p_auction_id
       AND (
			       bid_status = 'B'
			    OR bid_status IS NULL
			)
       AND auction_end_time <= v_now;

    /* 2) 잠금 후 상태 재확인 */
    SELECT auction_end_time, bid_status, user_id
      INTO v_end, v_status, v_seller_uid
      FROM auction_item
     WHERE auction_id = p_auction_id
     FOR UPDATE;

    /* 3) 최고입찰(가장 높은 금액, 동액이면 최근) */
    SELECT MAX(bid_amount) 
      INTO v_win_bid
      FROM auction_bid
     WHERE auction_id = p_auction_id;

    IF v_win_bid IS NULL THEN
        /* 유찰: 입찰 없음 → 종료만 표시 */
        UPDATE auction_item
           SET bid_status = 'N',
           	   posting_status = 'N'
         WHERE auction_id = p_auction_id;
        COMMIT;
        LEAVE proc;
    END IF;

    SELECT user_id, bid_id
      INTO v_win_uid, v_win_bid_id
      FROM auction_bid
     WHERE auction_id = p_auction_id
       AND bid_amount = v_win_bid
     ORDER BY bid_id DESC
     LIMIT 1;

    /* 4) 낙찰 입찰 success='Y' */
    UPDATE auction_bid
       SET success_status = 'Y'
     WHERE bid_id = v_win_bid_id;

    /* 5) 배송(주문) 생성 */
    INSERT INTO delivery (auction_id, receiver_user_id, send_user_id)
    VALUES (p_auction_id, v_win_uid, v_seller_uid);

    COMMIT;
END;
//
DELIMITER ;

-- 경매시간 종료 감지 프로시저

DELIMITER //

CREATE PROCEDURE sp_close_auctions()
BEGIN
    DECLARE v_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT auction_id
          FROM auction_item
         WHERE auction_end_time <= NOW(6)
            AND (
			       bid_status = 'B'
			    OR bid_status IS NULL
			)
         ORDER BY auction_end_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL sp_close_one_auction(v_id);
    END LOOP;
    CLOSE cur;
END;
//
DELIMITER ; 

-- 한 번만: 이벤트 스케줄러 ON (권한 필요)
SET GLOBAL event_scheduler = ON;

-- 매 1분마다 종료 경매 정산
-- DROP EVENT IF EXISTS ev_close_auctions;
CREATE EVENT ev_close_auctions
    ON SCHEDULE EVERY 1 MINUTE
    DO
      CALL sp_close_auctions();


-- 낙찰 및 유찰은 1분마다 종료시간 도달 시 자동 처리
-- 경매 수기 종료
CALL sp_close_one_auction(1);
-- 낙찰 종료 확인
SELECT * FROM auction_item;

SELECT * FROM auction_bid;

SELECT * FROM point_log;

SELECT * FROM user;
-- -------------------------------------------------------------

-- 6. 배송 
-- 최소 조건 : 낙찰 경매 물품, 입찰 및 판매 유저

-- 배송 완료 후 처리 트리거
DELIMITER //

CREATE TRIGGER trg_delivery_done
AFTER UPDATE ON delivery
FOR EACH ROW
BEGIN
    DECLARE v_price INT;
    DECLARE v_bid_id INT;
    DECLARE v_remain_sp INT;
	DECLARE v_seller_bp INT;
	DECLARE v_seller_new_bp INT;

    /* 배송 상태가 'S'로 갓 변경된 경우만 처리 (중복 방지) */
    IF NEW.delivery_status = 'S' AND (OLD.delivery_status IS NULL OR OLD.delivery_status <> 'S') THEN

        /* 1) 낙찰 금액/낙찰 bid_id 확보 (경매행 잠금) */
        SELECT current_price, auction_id
          INTO v_price, v_bid_id
          FROM auction_item
         WHERE auction_id = NEW.auction_id
         FOR UPDATE;

        SET v_price = IFNULL(v_price, 0);

        /* 2) 구매자 보관 포인트 잠금 & 잔액 확인 */
        SELECT IFNULL(stored_point, 0)
          INTO v_remain_sp
          FROM `user`
         WHERE user_id = NEW.receiver_user_id
         FOR UPDATE;
        
        IF v_remain_sp < v_price THEN
            /* 보관 포인트가 모자라면 배송완료 처리 자체를 막음 */
            SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = '보관 포인트가 부족하여 거래 차감을 진행할 수 없습니다.';
        END IF;
                
        /* 3) 판매자 포인트 잠금 & 잔액 확인 */
        SELECT IFNULL(user_balance, 0)
          INTO v_seller_bp
          FROM `user`
         WHERE user_id = NEW.send_user_id
         FOR UPDATE;

        /* 4) 구매자 stored_point 차감 */
        UPDATE `user`
           SET stored_point = stored_point - v_price
         WHERE user_id = NEW.receiver_user_id;

        /* 5) 판매자 point 증가 */
        UPDATE `user`
           SET user_balance = user_balance + v_price
         WHERE user_id = NEW.send_user_id;

        /* 6) 경매 상품 상태를 거래완료로 표시 */
        UPDATE auction_item
           SET bid_status = 'Y'
         WHERE auction_id = NEW.auction_id;

        /* 7) 변경된 판매자 포인트 조회 */
        SELECT IFNULL(user_balance, 0)
          INTO v_seller_new_bp
          FROM `user`
         WHERE user_id = NEW.send_user_id;
         
        /* 8) 포인트 로그 기록 */
        INSERT INTO point_log (
            trade_type, trade_amount, trade_explanation,
            bid_id, user_id, point_amount
        ) VALUES (
            'T',
            v_price,
            '배송 완료 확정',
            v_bid_id,
            NEW.send_user_id,
            v_seller_new_bp 
        );
    END IF;
END;
//
DELIMITER ;

-- 낙찰자 배송지 등록
UPDATE delivery 
	SET delivery_address = '서울 광진구 긴고랑로4길 13',
		  delivery_status = 'E',
          registered_at = NOW()
  WHERE delivery_id = 1;
  
-- 운송장 번호 등록 
UPDATE delivery 
	SET delivery_no = '5231582571234',
		  delivery_status = 'I'
  WHERE delivery_id = 1;
  
  

SELECT * FROM user;
SELECT * FROM delivery;

-- 배송 완료 확인 상태로 변경
UPDATE delivery 
	SET delivery_status = 'S',
        finished_at = NOW()
  WHERE delivery_id = 1;
  
-- 배송끝

-- ---------------------------------------------------------------
-- 7.리뷰&신고
-- 7-1. 리뷰 
-- 리뷰 추가 (한철수 -> 홍길동 "상품 상태가 좋아요" 별점 5점)
INSERT INTO review 
(
	review_star, 
	review_content, 
	review_status, 
	reviewer_id, 
	reviewee_id, 
	auction_id
) VALUES
(
	5,
	'상품 상태가 좋아요',
	'Y',
	4,
	1,
	1
);

INSERT INTO file
(
	auction_id,
	file_path,
	file_name,
	file_type,
	review_id
) VALUES 
(
	1,
	'/home/charly/image.png',
	'image',
	'png',
	1
);

-- 7-2. 신고
-- 신고 등록
-- 한철수 -> 홍길동 신고
-- 카테고리 드롭다운에서 '경매' 를 선택하면 category_id가 등록된다 
INSERT INTO report (
report_content , category_id , auction_id , reporter_id
) VALUES (
'홍길동이 상품설명과 다른 물건을 보냈어요',
(SELECT category_id FROM category WHERE category_name ='경매'),
(SELECT auction_id FROM auction_item WHERE auction_id = 1),
(SELECT user_id FROM user WHERE user_id = 4) 
);

SELECT * FROM report;

-- 신고 처리
-- report_action (답변) 에 글이 작성되면 
-- status를 Y 로 변경하는 트리거

DELIMITER //

CREATE TRIGGER update_report_action
BEFORE UPDATE ON report
FOR EACH ROW
BEGIN

 	DECLARE handler_role VARCHAR(15);

	IF NEW.report_action IS NOT NULL THEN
	
		-- 작성자가 admin인지 확인
		SELECT user_role 
      INTO handler_role
      FROM user
      WHERE user_id = NEW.handler_id;

      -- admin 아니면 에러
      IF handler_role != 'ADMIN' THEN
      	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '관리자만 답변을 등록할 수 있습니다.';
      END IF;

		
		SET NEW.report_status = 'Y';
		
		-- 필요하면 게시물 상태 변경
      IF NEW.report_action LIKE('%상품 비활성화%') THEN
			UPDATE auction_item
   		SET posting_status = 'N'  
      	WHERE auction_id = NEW.auction_id;
		END IF;
		
		
	END IF;
    
END //

DELIMITER ;

-- 신고처리
UPDATE report a
SET 
	a.report_action = '경고 조치 완료',
	a.handler_id = 3
WHERE a.report_id = 1;
SELECT * FROM auction_item;

-- 8. 로그
-- user_log 트리거
DELIMITER //

CREATE TRIGGER trg_user_update_log
AFTER UPDATE ON user
FOR EACH ROW
BEGIN
    -- 닉네임 변경
    IF NEW.user_nickname <> OLD.user_nickname THEN
        INSERT INTO user_log (user_id, user_log_content, column_name)
        VALUES (OLD.user_id,
                CONCAT('닉네임 변경: ', OLD.user_nickname, ' → ', NEW.user_nickname),
                'user_nickname');
    END IF;

    -- 전화번호 변경
    IF NEW.user_phone <> OLD.user_phone THEN
        INSERT INTO user_log (user_id, user_log_content, column_name)
        VALUES (OLD.user_id,
                CONCAT('전화번호 변경: ', OLD.user_phone, ' → ', NEW.user_phone),
                'user_phone');
    END IF;

    -- 비밀번호 변경
    IF NEW.user_password <> OLD.user_password THEN
        INSERT INTO user_log (user_id, user_log_content, column_name)
        VALUES (OLD.user_id,
                '비밀번호 변경 처리',
                'user_password');
    END IF;

    -- 이메일 변경
    IF NEW.user_email <> OLD.user_email THEN
        INSERT INTO user_log (user_id, user_log_content, column_name)
        VALUES (OLD.user_id,
                CONCAT('이메일 변경: ', OLD.user_email, ' → ', NEW.user_email),
                'user_email');
    END IF;

    -- 상태 변경
    IF NEW.user_status <> OLD.user_status THEN
        INSERT INTO user_log (user_id, user_log_content, column_name)
        VALUES (OLD.user_id,
                CONCAT('상태 변경: ', OLD.user_status, ' → ', NEW.user_status),
                'user_status');
    END IF;
END //

DELIMITER ;

-- 회원 정보 수정
-- 홍길동 닉네임 길동이 -> 홍길동짱
UPDATE user
	SET
		user_nickname = '홍길동짱'
	WHERE id = 'user01';
	
SELECT * FROM user;

-- ----------------------------------------------------------------------------------------
-- 9. 알림

-- 알림 위해서 실행


