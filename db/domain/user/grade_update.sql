-- USR_RNK_001
-- 회원 등급 산정
UPDATE user
SET grade_id = CASE
    WHEN trade_count >= 100 THEN 4   -- P
    WHEN trade_count >= 50  THEN 3   -- G
    WHEN trade_count >= 20  THEN 2   -- S
    ELSE 1                           -- 기본 등급 B
END
WHERE user_id = 1;


-- 거래 횟수가 업데이트 되면 등급도 자동 산정돼서 업데이트 되게끔
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