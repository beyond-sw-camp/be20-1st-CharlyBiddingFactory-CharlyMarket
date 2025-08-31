SELECT * FROM review;


-- 내 후기 목록 조회
-- 내가 쓴 후기들을 목록으로 간단하게 표시한다
SELECT 
	review_star '별점' , 
	review_content '리뷰내용', 
	a.user_name '판매자' , 
	b.auction_title '상품명'
FROM review
JOIN user a ON reviewee_id = a.user_id
JOIN auction_item b USING(auction_id)
WHERE reviewer_id = 2;


-- 내 후기 수정
-- 해당 리뷰가 내가 작성한 리뷰가 맞는지도 확인되야 된다
DELIMITER //

CREATE PROCEDURE update_review (
   IN check_review_id INT,
   IN check_user_id INT,
   IN update_review_star INT,
   IN update_review_content VARCHAR(999)
)
BEGIN
   -- 작성자 확인
   	IF NOT EXISTS (
      	SELECT 1
      	FROM review
      	WHERE review_id = check_review_id
      	AND reviewer_id = check_user_id
		) THEN
		
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '자신이 작성한 리뷰만 수정할 수 있습니다.';
        
   	END IF;

   	-- 리뷰 수정
   	UPDATE review
   	SET 
		review_star = update_review_star,
      review_content = update_review_content
    	WHERE review_id = check_review_id
      AND reviewer_id = check_user_id;

END //

DELIMITER ;



-- review_id , reviewer_id , review_star , review_content
CALL update_review(1,1,5,'나쁘지않네요'); -- 자신이 쓴것 정상update
CALL update_review(1,3,5,'나쁘지않네요'); -- 실패 : 자신이 쓴 리뷰가 아님
		
		
		
-- 내 후기 삭제
-- 내가 작성한 후기를 삭제한다
-- 리뷰 status를 'N'으로 변경하는 것
-- 수정과 비슷하나 리뷰어의 비밀번호까지 체크한 후 변경한다

DELIMITER //

CREATE PROCEDURE delete_review(
   IN check_review_id INT,
   IN check_user_id INT,
	IN check_user_password VARCHAR(50)
)
BEGIN
   -- 자신의 글이 맞는지 and 자신의 비밀번호가 맞는지
   IF NOT EXISTS (
      SELECT 1
      FROM review a
      JOIN user b ON a.reviewer_id = b.user_id
      WHERE a.review_id = check_review_id
      AND a.reviewer_id = check_user_id
      AND b.user_password = check_user_password
    ) THEN
    
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '작성자 비밀번호가 일치하지 않거나 작성자가 아닙니다.';
      
   END IF;

   -- 리뷰 상태를 'N'으로 변경
   UPDATE review
   SET review_status = 'N'
   WHERE review_id = check_review_id;
   
END //

DELIMITER ;
	
-- review_id , reviewer_id , user_password
CALL delete_review(1, 1, 'pw02'); -- 비밀번호 다를시 오류
CALL delete_review(1, 2, 'pw01'); -- 작성자가 아닐시 오류
CALL delete_review(1, 1, 'pw01'); -- 모두 맞을시 정상 update

-- ----------------------------------------------------------

-- 알림
SELECT * from alarm_box;

-- 내 알림 조회
-- 유저와 알람템플릿을 조인하여
-- 알림을 간단한 문구로 보여준다
-- 알림 확인 후 보여지지 않을거면 추후 수정
SELECT  CONCAT(a.user_name,'님! ',b.alarm_content) '알림 내용' , alarm_check
FROM alarm_box
JOIN user a USING(user_id)
JOIN alarm_template b USING(alarm_id)
WHERE user_id = 2;




-- 알람 삭제
-- 해당유저가 알람을 삭제한다
-- 알림을 확인한 것만 삭제
-- 알림을 어떻게 처리 할지 추후 회의필요
DELETE FROM alarm_box
WHERE user_id = 2 && alarm_check = 'Y' ;


