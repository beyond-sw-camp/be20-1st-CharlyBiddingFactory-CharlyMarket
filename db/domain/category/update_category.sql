-- 기존 카테고리 이름/타입 수정
UPDATE category
SET category_type = 'A',
		category_name = '수정된 카테고리명',
  	category_status = 'N'           
WHERE category_id = 1;      -- 수정할 카테고리 id
