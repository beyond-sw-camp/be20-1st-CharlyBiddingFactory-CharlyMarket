-- USR_UPD_002
-- 회원정보 수정
-- 회원 기본 정보 수정 (닉네임, 주소, 계좌번호 등)
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

-- 테스트용
UPDATE user
	SET
		user_nickname = '테스트'
	WHERE id = 'user01';
	
	
-- 프로필 사진 수정 (file 테이블에서 업데이트)
UPDATE file
SET file_path = '/upload/profile/updated_profile.jpg',
    file_name = 'updated_profile.jpg'
WHERE user_id = 2
  AND file_type = 'jpg';