  -- 카테고리 비활성화
UPDATE category
SET category_status = 'Y'   -- 'Y' 사용 / 'N' 미사용(삭제 처리)
WHERE category_id = 1;      -- 삭제 처리할 알람 id

-- 카테고리 단위로 여러 건 비활성화
UPDATE category
SET category_status = 'N'
WHERE category_id = 15
  AND category_status = 'Y';