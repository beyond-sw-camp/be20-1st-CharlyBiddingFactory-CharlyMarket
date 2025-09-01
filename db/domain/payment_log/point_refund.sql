-- PNT_REF_002 포인트 환불
Delimiter //
CREATE PROCEDURE refund_point(
    IN p_user_id INT,
    IN p_account_id INT, -- 회원이 자신의 계좌를 선택하는 상황
    IN p_conversion_amount INT -- 환불 원하는 금액
)

BEGIN
    DECLARE v_grade_name VARCHAR(5);-- 유저 등급명
    DECLARE v_grade_fee_rate DECIMAL(10,2); -- 등급별 수수료율
    DECLARE v_refund_to_user INT;   -- 유저에게 환불될 금액
    DECLARE v_admin_id INT;         -- 관리자 계정


    -- 유저 등급명과 수수료율 조회
    SELECT g.grade_name, g.grade_fee_rate INTO v_grade_name, v_grade_fee_rate
    FROM user u
    JOIN grade g ON u.grade_id = g.grade_id
    WHERE u.user_id = p_user_id;

    -- 등급 수수료율 적용하여 환불 계산
    SET v_refund_to_user = FLOOR(p_conversion_amount * (100 - v_grade_fee_rate) / 100);

    -- 관리자 계정 조회
    SELECT user_id INTO v_admin_id
    FROM user
    WHERE user_role = 'ADMIN'
    LIMIT 1;

    -- 관리자 잔고 업데이트 (수수료)
    UPDATE user
    SET user_balance = user_balance + (p_conversion_amount - v_refund_to_user)
    WHERE user_id = v_admin_id;

    -- 유저 잔고 차감 (전체 환불 포인트)
    UPDATE user
    SET user_balance = user_balance - p_conversion_amount
    WHERE user_id = p_user_id;

    -- 결제 로그 기록
    INSERT INTO payment_log(payment_type, account_id, user_id, payment_amount, conversion_amount, grade_name, point_amount)
    VALUES (
        'R',
        p_account_id,
        p_user_id,
        v_refund_to_user,
        p_conversion_amount,
        v_grade_name,
        (SELECT user_balance FROM user WHERE user_id = p_user_id)
    );

END //

delimiter ;


CALL refund_point(1, 1, 10000); -- 10000원 차감되고 9000포인트 차감  관리자1000원 이득