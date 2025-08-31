-- USR_FID_001
-- 아이디 찾기
SELECT id
	FROM user
	WHERE user_email = 'user01@example.com'
	   OR user_phone = '01042331101';