-- USR_LGN_001
-- 로그인
-- 사용자
SELECT *
	FROM user
	WHERE id = 'user01'
  	AND user_password = 'pw01';

-- 관리자
SELECT *
	FROM user
	WHERE id = 'admin01'
  	AND user_password = 'adminpw';