-- USR_REG_001
-- 회원가입
INSERT INTO user (
	user_role, 
	id, 
	user_password, 
	user_name, 
	user_phone, 
	user_email, 
	grade_id, 
	user_nickname
	) VALUES
		(
		'USER', 
		'user01', 
		'pw01', 
		'홍길동', 
		'01012345678', 
		'user01@example.com', 
		1, 
		'길동이'
		);