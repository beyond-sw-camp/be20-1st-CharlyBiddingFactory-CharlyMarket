-- 공지사항 파일 데이터
-- 공지사항 입력 (관리자가 작성:성공)
INSERT INTO
	notice(notice_title,notice_content,user_id)
	VALUES('경매 물품 가격 오류','경매물품 가격이 제대로 표시되지 않는 오류가 발생 했습니다.',5);	
INSERT INTO file (notice_id, file_path, file_name, file_type) VALUES
(1, '/home/charly/ima/iphone', 'iphone', 'jpg'); 



-- 공지사항 수정(공지사항 id=1)
UPDATE notice n
      LEFT JOIN file f ON n.notice_id = f.notice_id
   SET
      n.notice_title = '공지 사항 문제 발생',
      n.notice_content = ' 공지사항에 접근하지 말아주시길 바랍니다 .',
      n.updated_at = NOW(),
      f.file_path = '/do',
      f.file_name = 'err',
      f.file_type = 'jpg'
   WHERE 
      n.notice_id = 1;






-- 공지사항 삭제(공지사항 id=1)
DROP PROCEDURE delete_notice_check;
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
--  공지사항 id 1(활성화 상태)을 업데이트 할 떄
-- '관리자만 접근 가능 합니다.' 표시
CALL delete_notice_check (1);
-- 공지사항 id 1(비활성화 상태)을 업데이트 할 떄
-- '존재하지 않는 공지사항입니다.' 표시
CALL delete_notice_check (1);
 
 
 
	
-- 공지사항 목록  조회 (회원,관리자)
SELECT
	n.notice_id AS '공지사항 번호',
	n.notice_title  AS '제목',
	DATE(n.updated_at) AS '작성일자',
	u.user_nickname AS '작성자'
	FROM notice n
	JOIN user u ON n.user_id= u.user_id
	WHERE notice_status='Y'
	ORDER BY n.updated_at DESC
	LIMIT 10 OFFSET 0;
-- 공지사항 조회 관리자

	
-- 등록된 공지사항 상세 조회 (notice id=1,file_id=2)
SELECT
	n.notice_id AS '공지사항 번호',
	n.notice_title AS '제목',
	n.notice_content AS '내용',
	DATE(n.updated_at) AS '작성일자',
	n.notice_status AS '공지 상태',
	u.user_nickname AS '작성자',
	f.file_path,
	f.file_name,
	f.file_type
	FROM notice n
	JOIN user u ON n.user_id=u.user_id
	LEFT JOIN file f ON n.notice_id=f.notice_id
	WHERE n.notice_status='Y' AND n.notice_id=3; 