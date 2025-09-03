-- PNT_SRC_004 포인트 조회

-- 회원의 잔고 값으로 업데이트 안하고 조회하는 ver.

DELIMITER $$

CREATE PROCEDURE get_user_point(
    IN p_user_id INT,
    IN p_source VARCHAR(10),
    OUT p_point INT
)
BEGIN
    -- 초기값 0
    SET p_point = 0;

    IF p_source = 'my' THEN
        -- 1️회원 테이블에서 조회
        SELECT user_balance INTO p_point
        FROM user
        WHERE user_id = p_user_id;

    ELSEIF p_source = 'pay' THEN
        -- 2️결제 이력에서 최신 포인트 조회
        SELECT point_amount INTO p_point
        FROM payment_log
        WHERE user_id = p_user_id
        ORDER BY created_at DESC
        LIMIT 1;

    ELSEIF p_source = 'point' THEN
        -- 3️포인트 이력에서 최신 포인트 조회
        SELECT point_amount INTO p_point
        FROM point_log
        WHERE user_id = p_user_id
        ORDER BY created_at DESC
        LIMIT 1;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid source. Use my, pay, or point.';
    END IF;

END $$

DELIMITER ;

-- mypage
SET @current_point = 0;

CALL get_user_point(101, 'my', @current_point);

SELECT @current_point;

-- 결제이력
SET @current_point = 0;

CALL get_user_point(2, 'pay', @current_point);

SELECT @current_point;

-- point_log

SET @current_point = 0;

CALL get_user_point(1, 'point', @current_point);

SELECT @current_point;

-- 회원의 잔고로 업데이트하는 ver.
DELIMITER $$

CREATE PROCEDURE get_user_point_update(
    IN p_user_id INT,
    IN p_source VARCHAR(10),
    OUT p_point INT
)
BEGIN
    DECLARE v_latest_point INT;

    SET p_point = 0;

    IF p_source = 'my' THEN
        -- 1️회원 테이블에서 조회
        SELECT user_balance INTO p_point
        FROM user
        WHERE user_id = p_user_id;

    ELSEIF p_source = 'pay' THEN
        -- 2️결제 이력에서 최신 포인트 조회
        SELECT point_amount INTO v_latest_point
        FROM payment_log
        WHERE user_id = p_user_id
        ORDER BY created_at DESC
        LIMIT 1;

        IF v_latest_point IS NOT NULL THEN
            -- user 테이블 업데이트
            UPDATE user
            SET user_balance = v_latest_point
            WHERE user_id = p_user_id;

            SET p_point = v_latest_point;
        ELSE
            SET p_point = 0;
        END IF;

    ELSEIF p_source = 'point' THEN
        -- 3 포인트 이력에서 최신 포인트 조회
        SELECT point_amount INTO v_latest_point
        FROM point_log
        WHERE user_id = p_user_id
        ORDER BY created_at DESC
        LIMIT 1;

        IF v_latest_point IS NOT NULL THEN
            -- user 테이블 업데이트
            UPDATE user
            SET user_balance = v_latest_point
            WHERE user_id = p_user_id;

            SET p_point = v_latest_point;
        ELSE
            SET p_point = 0;
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid source. Use my, pay, or point.';
    END IF;

END $$

DELIMITER ;