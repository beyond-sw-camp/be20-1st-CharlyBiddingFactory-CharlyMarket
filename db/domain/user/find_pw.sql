-- USR_RPW_001
-- 비밀번호 찾기
UPDATE user
	SET user_password = 'newpassword123'
	WHERE id = 'user01';