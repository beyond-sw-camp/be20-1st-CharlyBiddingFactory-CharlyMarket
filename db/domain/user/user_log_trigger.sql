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