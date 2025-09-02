-- 1. 회원 가입 & 등급
-- 1-1. 등급 (grade) 생성
INSERT INTO grade (grade_name, grade_fee_rate, grade_standard) VALUES
('B', 10.00, 0),
('S', 7.00, 20),
('G', 5.00, 50),
('P', 3.00, 100);

SELECT * FROM grade;

-- 1-* 회원등급 트리거
-- 거래 횟수(user 테이블의 trade_count)에 따라 등급 자동으로 바뀌는 트리거
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