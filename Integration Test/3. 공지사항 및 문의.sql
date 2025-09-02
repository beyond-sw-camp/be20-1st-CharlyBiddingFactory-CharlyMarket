-- 3. 공지사항 & 문의
-- 3-1. 문의사항 등록

INSERT INTO inquiry(inquiry_title,inquiry_content,user_id)VALUES 
('배송 관련 문의드립니다.','배송이 너무 오래걸려 문의 드립니다. 도착예정일을 알 수 있을까요',1);
INSERT INTO file(inquiry_id,file_path,file_name, file_type)VALUES
(1,'/home/charly/ima/iphone', 'iphone','jpg' ); 
INSERT INTO inquiry(inquiry_title,inquiry_content,user_id)VALUES 
('포인트 관련 문의 드립니다.','포인트가 제대로 충전이 안됩니다. 해결 부탁드려요',2);

SELECT * FROM inquiry;

-- 관리자 문의 답변

DELIMITER //
CREATE PROCEDURE update_inquiry_answer(
    IN check_user_id INT,    -- 사용자의 ID
    IN check_inquiry_id INT   -- 수정할 공지사항의 ID
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
			  inquiry_answer='빠른 시일 내 해결하겠습니다.',
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

-- 관리자가 1번 문의 답변
CALL UPDATE_inquiry_answer(3,1);


SELECT * FROM inquiry;



-- 3-2. 공지
-- 공지사항 등록 (관리자가 작성:성공)
INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('경매 물품 가격 오류 공지','경매물품 가격이 제대로 표시되지 않는 오류가 발생 했습니다.',3);

INSERT INTO file (notice_id, file_path, file_name, file_type) VALUES
(1, '/home/charly/ima/iphone', 'iphone', 'jpg'); 

INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('경매 입찰 오류 공지','경매물품 입찰이 제대로 되지 않는 오류가 발생 했습니다.',3);		
INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('등급 오류 공지','회원 등급이 비정상 적용 되는 오류가 발생 했습니다.',3);		

SELECT * FROM notice;


-- 공지사항 수정(공지사항 id=1)
UPDATE notice n
      LEFT JOIN file f ON n.notice_id = f.notice_id
   SET
      n.notice_title = '공지사항 문제 발생',
      n.notice_content = ' 공지사항에 접근하지 말아주시길 바랍니다 .',
      n.updated_at = NOW(),
      f.file_path = '/do',
      f.file_name = 'err',
      f.file_type = 'jpg'
   WHERE 
      n.notice_id = 2;



SELECT * FROM notice;


-- 공지사항 삭제(공지사항 id=1)
DELIMITER //

CREATE PROCEDURE delete_notice_check(
    IN check_notice_id INT   -- 수정할 공지사항의 ID
)
BEGIN
    DECLARE check_notice_status CHAR(1);
    
    --  공지사항이 활성화 상태인지 확인
   SELECT notice_status
	   INTO check_notice_status
		FROM notice
	WHERE notice_id = check_notice_id;

    IF check_notice_status ='Y' THEN
        UPDATE notice n
        SET
            n.notice_status = 'N'
        WHERE 
            n.notice_id = check_notice_id;
        SELECT '공지사항이 삭제되었습니다.' AS result;
        -- 유저가 admin이 아닐 떄
    ELSEIF check_notice_status != 'Y' THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 제거 된 공지사항입니다.';
    END IF;

END//

DELIMITER ;

CALL delete_notice_check (2);
SELECT * FROM notice;