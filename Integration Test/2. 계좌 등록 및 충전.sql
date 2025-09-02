-- 2. 계좌등록 & 충전
-- 2-1. 회원 계좌 등록
INSERT INTO account (bank_name, account_no, bank_owner, user_id)
VALUES ('농협은행', '111-222-333', '홍길동', 1),
('신한은행', '444-555-666', '김영희', 2),
('우리은행', '777-888-999', '한철수', 4);

-- 2.2 포인트 충전
-- 포인트 충전 프로시저 (회원아이디, 계좌아이디, 충전금액 입력)

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