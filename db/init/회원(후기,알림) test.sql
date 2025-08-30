SELECT * FROM review;


-- 내 후기 목록 조회
-- 내가 쓴 후기들을 목록으로 간단하게 표시한다
SELECT review_star , review_content , a.user_name '판매자' , b.auction_title '상품명'
FROM review
JOIN user a ON reviewee_id = a.user_id
JOIN auction_item b USING(auction_id)
WHERE reviewer_id = 2;


-- 후기 수정
-- 내가 작성한 후기목록 중 하나를 선택하면 해당 상품으로 다시 넘어가 수정한다
-- review_id 와 reviewer_id 가 같아야 업데이트 된다
UPDATE review
SET	review_star = 3,
		review_content = '상품이 생각보다 자주 고장나네요!!'
WHERE review_id = 1
AND reviewer_id = 1;
		
		
		
-- 내 후기 삭제
-- 내가 작성한 후기를 삭제한다
-- 리뷰 status를 'N'으로 변경하는 것
-- 수정과 비슷하나 리뷰어의 비밀번호까지 체크한 후 변경한다

UPDATE review 
JOIN user a ON reviewer_id = a.user_id
SET review_status = 'N'
WHERE review_id = 1
AND reviewer_id = 1
AND a.user_password = 'pw01';

SELECT * FROM review;



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







