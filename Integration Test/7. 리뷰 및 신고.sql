-- 7.리뷰&신고
-- 7-1. 리뷰 
-- 리뷰 추가 (한철수 -> 홍길동 "상품 상태가 좋아요" 별점 5점)
INSERT INTO review 
(
	review_star, 
	review_content, 
	review_status, 
	reviewer_id, 
	reviewee_id, 
	auction_id
) VALUES
(
	5,
	'상품 상태가 좋아요',
	'Y',
	4,
	1,
	1
);

INSERT INTO file
(
	auction_id,
	file_path,
	file_name,
	file_type,
	review_id
) VALUES 
(
	1,
	'/home/charly/image.png',
	'image',
	'png',
	1
);

-- 7-2. 신고
-- 신고 등록
-- 한철수 -> 홍길동 신고
-- 카테고리 드롭다운에서 '경매' 를 선택하면 category_id가 등록된다 
INSERT INTO report (
report_content , category_id , auction_id , reporter_id
) VALUES (
'홍길동이 상품설명과 다른 물건을 보냈어요',
(SELECT category_id FROM category WHERE category_name ='경매'),
(SELECT auction_id FROM auction_item WHERE auction_id = 1),
(SELECT user_id FROM user WHERE user_id = 4) 
);

SELECT * FROM report;

-- 신고 처리
-- report_action (답변) 에 글이 작성되면 
-- status를 Y 로 변경하는 트리거

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

-- 신고처리
UPDATE report a
SET 
	a.report_action = '경고 조치 완료',
	a.handler_id = 3
WHERE a.report_id = 1;
SELECT * FROM auction_item;