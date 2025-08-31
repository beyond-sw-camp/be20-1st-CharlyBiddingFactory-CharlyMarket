-- USR_DEL_001
-- 회원 탈퇴
-- 탈퇴
UPDATE user
	SET user_status = 'N'
 WHERE user_id = 2;
 
-- 회원 비활성화(계정 정지)
UPDATE user
	SET user_status = 'B'
 WHERE user_id = 2;