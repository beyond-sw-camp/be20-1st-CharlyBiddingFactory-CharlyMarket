-- 신고
-- 신고 등록시간 , 처리현황 default 값을 수정 했습니다
ALTER TABLE report ALTER COLUMN report_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE report ALTER COLUMN report_status SET DEFAULT 'N';
-- 관리자 handler_id 는 답변을 작성할때 들어가는 것이므로 null 허용으로 바꾸셔야합니다 
ALTER TABLE report MODIFY handler_id INT NULL;


-- 신고 등록
-- (1)
-- 2번 유저가 1번 물품에 대해서 신고를 한다
-- 카테고리 드롭다운에서 '경매' 를 선택하면 category_id가 등록된다 
INSERT INTO report (
report_content, category_id , auction_id , reporter_id 
) VALUES (
'물품이 부서져 있어요',
(SELECT category_id FROM category WHERE category_name ='경매'),
(SELECT auction_id FROM auction_item WHERE auction_id = 1),
(SELECT user_id FROM user WHERE user_id = 2) 
);


SELECT * FROM report;



-- 신고 등록
-- (2) 
-- 카테고리만 바꿔서 등록해본다
INSERT INTO report (
report_content, category_id , auction_id , reporter_id 
) VALUES (
'배송품이 벽돌이 왔어요',
(SELECT category_id FROM category WHERE category_name ='배송'),
(SELECT auction_id FROM auction_item WHERE auction_id = 1),
(SELECT user_id FROM user WHERE user_id = 2) 
);

SELECT * FROM auction_item;

-- 신고 등록 실패
-- 없는 물품 id 로 등록해본다
INSERT INTO report (
report_content, category_id , auction_id , reporter_id 
) VALUES (
'배송품이 벽돌이 왔어요',
(SELECT category_id FROM category WHERE category_name = '배송'),
(SELECT auction_id FROM auction_item WHERE auction_id = 9),
(SELECT user_id FROM user WHERE user_id = 3) 
);

SELECT * FROM delivery;

-- ----------------------------------------------------------------------

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






-- 내 신고 사항 목록 조회
-- (1) 2번 유저가 자신의 신고사항 전체목록을 조회한다
-- reporter_id 는 조회를 한 user_id 값이 들어간다
-- 신고내용, 처리상태 , 신고물품 , 작성자이름 을 목록화 하여서 보여준다
SELECT report_id, report_content , report_status , b.auction_title, c.user_name
FROM report 
JOIN auction_item b USING(auction_id)
JOIN user c ON reporter_id = c.user_id
WHERE reporter_id = (SELECT user_id FROM user WHERE user_id = 2 );


SELECT report_id, report_content , report_at, report_status , b.auction_title, c.user_name
FROM report 
JOIN auction_item b USING(auction_id)
JOIN user c ON reporter_id = c.user_id
WHERE reporter_id = (SELECT user_id FROM user WHERE user_id = 2 );

SELECT * FROM report;



-- 신고목록 상세조회
-- 신고 목록중 하나를 선택하면  report_id 를 가져와서 자세한 정보를 보여준다
-- 답변내용 , 신고 카테고리 이름 , 작성자 이름 , 관리자 이름 

SELECT 
    a.report_id, 
    a.report_content, 
    a.report_at, 
    a.report_status, 
    IFNULL (a.report_action,'답변내용없음') AS '답변내용',
    b.auction_title,
    e.category_name, 
    c.user_name AS '작성자',  
    IFNULL(d.user_name,'답변자 배정중') AS '답변자'   
FROM report a
JOIN auction_item b USING(auction_id)
JOIN category e ON a.category_id = e.category_id
JOIN user c ON a.reporter_id = c.user_id
JOIN user d ON a.handler_id = d.user_id  
WHERE a.report_id = 1;


-- 관리자 신고전체목록 조회
-- 관리자일시 들어온 신고목록 전체를 조회한다
-- 조회하는 유저의 role이 admin 이 아닐경우 조회결과가 안나오도록 한다
-- d.user_id = 4 : 조회하는 유저의 코드 (5번이 관리자)
SELECT a.report_id, a.report_content , a.report_at, a.report_status , b.auction_title, c.user_name
FROM report a
JOIN auction_item b USING(auction_id)
JOIN user c ON a.reporter_id = c.user_id
JOIN user d ON d.user_id = 5
WHERE d.user_role = 'ADMIN';




-- 관리자 신고목록 상세조회
-- 조회하는 유저의 role이 admin 이 아닐경우 조회결과가 안나오도록 한다
-- d.user_id = 4 : 조회하는 유저의 코드 (5번이 관리자)
-- d.user_id = 5 일시 조회결과 출력
SELECT 
    a.report_id, 
    a.report_content, 
    a.report_at, 
    a.report_status, 
    IFNULL (a.report_action,'답변내용없음') AS '답변내용',
    b.auction_title,
    e.category_name, 
    c.user_name AS '작성자',  
    IFNULL(d.user_name,'답변자 배정중') AS '답변자'   
FROM report a
JOIN auction_item b USING(auction_id)
JOIN category e ON a.category_id = e.category_id
JOIN user c ON a.reporter_id = c.user_id
JOIN user d ON a.handler_id = d.user_id 
JOIN user f ON f.user_id = 5
WHERE a.report_id = 1 && f.user_role = 'ADMIN';




-- 신고 처리 후 
-- 신고상태 변경
-- report_action (답변) 에 글이 작성되면 
-- status를 Y 로 변경
DELIMITER //

CREATE TRIGGER update_report_status
BEFORE UPDATE ON report
FOR EACH ROW
BEGIN

	IF OLD.report_action IS NULL 
	AND NEW.report_action IS NOT NULL THEN
		
		SET NEW.report_status = 'Y';
		
	END IF;
    
END;
//

DELIMITER ;

SELECT * FROM report;

-- 기본 데이터에 hanler_id 가 존재하므로 삭제
UPDATE report
SET handler_id = NULL;



-- 1번 신고사항 상세보기로 들어온상태
-- 들어올때 관리자인걸 확인 했지만
-- 한번 더 확인해보고 handler_id에 넣는다
UPDATE report a
JOIN user b ON b.user_id = 5 AND b.user_role = 'ADMIN'
SET 
	a.report_action = '조치 완료!',
	a.handler_id = b.user_id
WHERE a.report_id = 1;






-- 신고 처리 후 
-- 게시물 상태 변경 ( 숨김 )
-- report_action (답변) 에 글이 작성되면 
-- status를 Y 로 변경
-- auction_item posting_status = 'N' 로 변경
DELIMITER //

CREATE TRIGGER update_report_status_aution_item_blind
BEFORE UPDATE ON report
FOR EACH ROW
BEGIN

	IF OLD.report_action IS NULL 
	AND NEW.report_action IS NOT NULL THEN
		
		SET NEW.report_status = 'Y';
		
		
		UPDATE auction_item
   	SET posting_status = 'N'  
      WHERE auction_id = NEW.auction_id;
		
	END IF;
    
END;
//

DELIMITER ;



-- 2번 신고사항 조치
-- 위에 트리거를 통해 해당 auction_id 의 게시물 비활성화 확인
-- 2번 신고사항 aution_id = 2
UPDATE report a
JOIN user b ON b.user_id = 5 AND b.user_role = 'ADMIN'
SET 
	a.report_action = '조치완료 해당 상품 비활성화 되었습니다',
	a.handler_id = b.user_id
WHERE a.report_id = 2;

SELECT * FROM report;
SELECT posting_status FROM auction_item;




