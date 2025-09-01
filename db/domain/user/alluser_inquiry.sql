-- USR_SRC_001
-- 전체 회원 조회
SELECT 
		user_id,
		user_role,
		id,
		user_password,
		user_name,
		user_phone,
		user_email,
		user_status,
		grade_id,
		user_balance,
		trade_count,
		user_nickname,
		stored_point
	FROM user;