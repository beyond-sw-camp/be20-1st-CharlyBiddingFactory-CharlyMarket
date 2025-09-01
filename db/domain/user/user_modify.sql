-- USR_UPD_001
-- 전체 회원 수정
UPDATE user
	SET
		user_role = '', 
		id = '', 
		user_password = '', 
		user_name = '', 
		user_phone = '', 
		user_email = '', 
		grade_id = '', 
		user_nickname = ''
	WHERE id = 'user01';