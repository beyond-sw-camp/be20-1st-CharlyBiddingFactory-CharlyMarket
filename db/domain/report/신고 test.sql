-- 신고 등록
-- (1)
-- 2번 유저가 1번 물품에 대해서 신고를 한다
-- 카테고리 드롭다운에서 '경매' 를 선택하면 category_id가 등록된다 
INSERT INTO report (
report_content , category_id , auction_id , reporter_id
) VALUES (
'물품이 부서져 있어요',
(SELECT category_id FROM category WHERE category_name ='경매'),
(SELECT auction_id FROM auction_item WHERE auction_id = 1),
(SELECT user_id FROM user WHERE user_id = 2) 
);

-- ----------------------------------------------------------------------
-- (2)
-- 배송시 문제가 생겼을 때 신고
-- 배송에 문제가 생겼을 시에는
-- acution_id 와 reporter_id 는 delivery_id 를 통해 가져온다

INSERT INTO report (
  report_content, category_id, auction_id, reporter_id
) VALUES (
  '배송품이 벽돌이 왔어요',
  (SELECT category_id FROM category WHERE category_name = '배송'),
  (SELECT auction_id FROM delivery WHERE delivery_id = 2), 
  (SELECT reciver_user_id FROM delivery WHERE delivery_id = 2) 
);

SELECT * FROM report;




-- ----------------------------------------------------------------------------
-- 내 신고 사항 목록 조회
-- 관리자 일시 전체 목록조회
-- 신고내용, 처리상태 , 신고물품 , 작성자이름 을 목록화 하여서 보여준다
DELIMITER //

CREATE PROCEDURE report_select_list (
	IN check_user_id INT -- 선택한 유저의 id
)

BEGIN
	DECLARE check_user_role VARCHAR(15);
	
	SELECT user_role INTO check_user_role
   FROM user
   WHERE user_id=check_user_id; -- 선택한 유저의 id (로그인한 유저id)
   
case 
		when check_user_role = 'USER' then -- user일시 자신의 신고목록만 조회
   
		SELECT 
			report_id '신고번호',
			report_content '신고내용',
			report_status '처리상태',
			b.auction_title '상품명',
			c.user_name '신고자'
		FROM report 
		JOIN auction_item b USING(auction_id)
		JOIN user c ON reporter_id = c.user_id
		WHERE reporter_id = check_user_id;
		
		when check_user_role = 'ADMIN' then -- admin일시 전체 신고목록조회
		
		SELECT 
			a.report_id '신고번호',
			a.report_content '신고내용',
			a.report_at '신고작성시간', 
			a.report_status '처리상태', 
			b.auction_title '상품명', 
			c.user_name '신고자명',
			d.user_name '관리자명'
		FROM report a
		JOIN auction_item b USING(auction_id)
		JOIN user c ON a.reporter_id = c.user_id
		left JOIN user d ON a.handler_id = d.user_id;
		
		else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '로그인 정보가 없습니다.';
		
END CASE;		

END //

DELIMITER ;

CALL report_select_list(3); -- 일반 유저일시 자기 목록만
CALL report_select_list(5); -- 관리자일시 전체 목록
CALL report_select_list(8); -- 없는 유저일시 오류 메세지 출력





-- 신고 목록 상세 조회
-- 목록중 하나를 선택한다
-- 내가 작성한게 아니면 or 관리자가 아니면  오류메세지 띄움
DELIMITER //

CREATE PROCEDURE report_select_detail (
    IN check_user_id INT,   -- 로그인한 유저 id
    IN check_report_id INT  -- 상세조회할 신고 id
)
BEGIN
    DECLARE check_user_role VARCHAR(15);
	 DECLARE owner_check INT;
	 
    -- 유저 권한조회
    SELECT user_role 
    INTO check_user_role
    FROM user
    WHERE user_id = check_user_id;

    -- USER 권한일 경우 : 본인이 신고한 건만 조회 가능
    IF check_user_role = 'USER' THEN
    
		SELECT COUNT(*) -- 자신이 신고한 것이 맞는지 확인
		INTO owner_check
      FROM report
      WHERE report_id = check_report_id
      AND reporter_id = check_user_id;

			IF owner_check = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '자신의 신고사항만 조회할 수 있습니다.';
      	ELSE
        
	        SELECT 
	            a.report_id AS '신고번호', 
	            a.report_content AS '신고내용', 
	            a.report_at AS '신고등록시간', 
	            a.report_status AS '처리상태', 
	            IFNULL(a.report_action,'답변내용없음') AS '답변내용',
	            b.auction_title AS '상품명',
	            e.category_name AS '카테고리명', 
	            c.user_name AS '작성자',  
	            IFNULL(d.user_name,'답변자 배정중') AS '답변자'   
	     		FROM report a
	     		JOIN auction_item b USING(auction_id)
	     		JOIN category e ON a.category_id = e.category_id
	        	JOIN user c ON a.reporter_id = c.user_id
	        	LEFT JOIN user d ON a.handler_id = d.user_id  
	        	WHERE a.report_id = check_report_id
	        	AND a.reporter_id = check_user_id; -- 본인 것만 허용
          
			END IF;

    -- ADMIN 권한일 경우 : 모든 신고 상세조회 가능
    ELSEIF check_user_role = 'ADMIN' THEN
      	SELECT 
            a.report_id AS '신고번호', 
            a.report_content AS '신고내용', 
            a.report_at AS '신고등록시간', 
            a.report_status AS '처리상태', 
            IFNULL(a.report_action,'답변내용없음') AS '답변내용',
            b.auction_title AS '상품명',
            e.category_name AS '카테고리명', 
            c.user_name AS '작성자',  
            IFNULL(d.user_name,'답변자 배정중') AS '답변자'   
      	FROM report a
      	JOIN auction_item b USING(auction_id)
      	JOIN category e ON a.category_id = e.category_id
      	JOIN user c ON a.reporter_id = c.user_id
      	LEFT JOIN user d ON a.handler_id = d.user_id  
      	WHERE a.report_id = check_report_id;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '권한이 없습니다.';
        
    END IF;
END //

DELIMITER ;

-- 유저id , 신고id
CALL report_select_detail(2,1); -- 자신의 신고사항이면 확인가능
CALL report_select_detail(5,1); -- admin일경우 전부 확인가능
CALL report_select_detail(3,1); -- user가 자신의 신고글이 아니면 오류메세지


-- ---------------------------------------------------------------

-- 신고 처리 후 
-- 신고상태 변경
-- report_action (답변) 에 글이 작성되면 
-- status를 Y 로 변경
-- 필요에 따라 게시물 비활성화등 조건 추가 가능
DELIMITER //

CREATE TRIGGER update_report_action
BEFORE UPDATE ON report
FOR EACH ROW
BEGIN

 	DECLARE handler_role VARCHAR(15);

	IF NEW.report_action IS NOT NULL THEN
	
		-- 작성자가 admin인지 확인
		SELECT user_role 
      INTO handler_role
      FROM user
      WHERE user_id = NEW.handler_id;

      -- admin 아니면 에러
      IF handler_role != 'ADMIN' THEN
      	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '관리자만 답변을 등록할 수 있습니다.';
      END IF;

		
		SET NEW.report_status = 'Y';
		
		-- 필요하면 게시물 상태 변경
      IF NEW.report_action LIKE('%상품 비활성화%') THEN
			UPDATE auction_item
   		SET posting_status = 'N'  
      	WHERE auction_id = NEW.auction_id;
		END IF;
		
		
	END IF;
    
END //

DELIMITER ;





-- handler_id 의 유저가 admin이 아니어서 실패
UPDATE report a
SET 
	a.report_action = '조치 완료되었습니다',
	a.handler_id = 5
WHERE a.report_id = 1;

-- 답변내용에 상품 비활성화 를 넣어서 비활성화 확인
UPDATE report a
SET 
	a.report_action = '조치완료 상품 비활성화 되었습니다',
	a.handler_id = 5
WHERE a.report_id = 2;

