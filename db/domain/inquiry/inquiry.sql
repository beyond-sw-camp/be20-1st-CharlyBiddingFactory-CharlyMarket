-- 문의 등록
-- 일반 회원이 문의 사항 등록 
INSERT INTO
	inquiry(
	inquiry_title,
	inquiry_content,
	user_id)
VALUES 
('배송 관련 문의드립니다.',
'배송이 너무 오래걸려 문의 드립니다. 도착예정일을 알 수 있을 까요',
1
);
INSERT INTO file (inquiry_id, file_path, file_name, file_type) VALUES
(1, '/home/charly/ima', 'iphone', 'jpg'); 
	

-- 내 문의 목록 조회 (유저 아이디:1, 전체 문의 상태)
SELECT
	i.inquiry_id AS '문의글 번호',
	i.inquiry_title AS '제목',
	i.inquiry_status AS '문의 상태',
	i.created_at AS '작성 시간',
	u.user_name AS '유저 이름'
	FROM inquiry i
	JOIN user u ON i.user_id=u.user_id
	WHERE i.user_id=1
	ORDER BY i.created_at DESC
	LIMIT 10 OFFSET 0; 
	
-- 내 문의 목록 조회 답변 완료 목록(유저 아이디:1, 문의상태 :Y)
SELECT
	i.inquiry_id AS '문의글 번호',
	i.inquiry_title AS '문의 제목',
	i.inquiry_status AS '문의 상태',
	i.created_at AS '작성 시간',
	i.finished_at AS '답변 시간',
	u.user_nickname AS '유저 이름'
	FROM inquiry i
	JOIN user u ON i.user_id=u.user_id
	WHERE i.user_id=1 AND i.inquiry_status='Y'	
	ORDER BY i.finished_at DESC
	LIMIT 10 OFFSET 0; 
	
	
-- 내 문의 목록 상세 조회
DROP PROCEDURE select_inquiry_check;

DELIMITER //

CREATE PROCEDURE select_inquiry_check(
    IN check_user_id INT,    -- 사용자의 ID
    IN check_inquiry_id INT   -- 수정할 문의 글의 ID
)
BEGIN
    DECLARE inquiry_user_id INT;
    DECLARE check_user_role VARCHAR(15);

   SELECT user_id INTO inquiry_user_id
   	FROM inquiry
   WHERE inquiry_id=check_inquiry_id;
   
   SELECT user_role INTO check_user_role
   	FROM user
   WHERE user_id=check_user_id;
	IF check_user_id=inquiry_user_id OR check_user_role='ADMIN' THEN

   	SELECT
			i.inquiry_id AS '문의글 번호',
			i.inquiry_title AS '제목',
			i.inquiry_content AS '내용',
			i.inquiry_status AS '문의 상태',
			i.created_at AS '작성 시간',
			i.finished_at AS '처리 완료 시간',
			i.inquiry_answer AS '문의 답변',
			u.user_nickname AS '작성자',
			a.user_nickname AS '관리자',
			f.file_path,
			f.file_name,
			f.file_type 
			FROM inquiry i
			JOIN user u ON i.user_id=u.user_id
			LEFT JOIN user a ON i.admin_id=a.user_id
			LEFT JOIN file f ON i.inquiry_id=f.inquiry_id 
			WHERE i.inquiry_id=check_inquiry_id ;
 		ELSE  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '본인이 문의한 글이 아닙니다.';
    
			
	 END IF;
	END//
DELIMITER ;
-- 일반 유저의 본인 작성 글
CALL select_inquiry_check(1,1);
-- 일반 유저의 다른 사람 작성글(오류 발생)
CALL select_inquiry_check(1,2);
-- 관리자 유저의 다른 사람 작성글 
CALL select_inquiry_check(5,1);

-- 관리자가 문의 목록 전체 조회
SELECT
	i.inquiry_id,
	i.inquiry_title,
	i.inquiry_status,
	i.created_at,
	u.user_nickname
	FROM inquiry i
	JOIN user u ON i.user_id = u.user_id
	WHERE 'ADMIN'=(
					SELECT user_role
					 FROM user
					WHERE user_id =5)
	ORDER BY i.created_at DESC
	LIMIT 10 OFFSET 0; 
					
-- 관리자가 답변되지 않은 목록 전체 조회
SELECT
	i.inquiry_id,
	i.inquiry_title,
	i.inquiry_status,
	i.created_at,
	u.user_nickname
	FROM inquiry i
	JOIN user u ON i.user_id = u.user_id
WHERE i.inquiry_status='N' AND 'ADMIN'=(
					SELECT user_role
					 FROM user
					WHERE user_id =5)
	ORDER BY i.created_at ASC
	LIMIT 10 OFFSET 0 ; 

-- ---------------------------------------------------------------------------------------	
-- 관리자 문의 답변
DROP PROCEDURE update_inquiry_answer;

DELIMITER //
CREATE PROCEDURE update_inquiry_answer(
    IN check_user_id INT,    -- 사용자의 ID
    IN check_inquiry_id INT   -- 수정할 문의 글의 ID
)
BEGIN
    DECLARE check_inquiry_status CHAR(1);
    DECLARE check_user_role VARCHAR(15);

   SELECT user_role INTO check_user_role
   	FROM user
   WHERE user_id=check_user_id;
   
   SELECT inquiry_status INTO check_inquiry_status
   	FROM inquiry
   WHERE inquiry_id=check_inquiry_id;
   
	IF check_inquiry_status='N' AND check_user_role='ADMIN' THEN
		UPDATE inquiry
		 SET inquiry_status='Y',
		 	  finished_at=NOW(),
			  inquiry_answer='112234',
			  admin_id=check_user_id
		 WHERE inquiry_id =check_inquiry_id;	
		 SELECT '답변이 완료되었습니다.';	  
 	ELSEIF check_inquiry_status='Y' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '답변이 완료된 문의글 입니다.';
   ELSEIF check_user_role!='ADMIN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '권한이 없습니다.';
	 END IF;
	END//
DELIMITER ;
CALL UPDATE_inquiry_answer(5,1);
CALL UPDATE_inquiry_answer(5,1);
