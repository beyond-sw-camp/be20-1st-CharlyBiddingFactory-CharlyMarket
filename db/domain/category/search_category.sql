-- 모든 카테고리 목록 조회
SELECT 
    c.category_id   AS "카테고리 id",
    c.category_type AS "카테고리 타입",
    c.category_name AS "카테고리 name",
    c.category_status AS "카테고리 사용여부"
FROM category c
ORDER BY c.category_id ASC;

-- 카테고리별 조회
SELECT 
    c.category_id     AS "카테고리 id",
    c.category_type   AS "카테고리 타입",
    c.category_name   AS "카테고리 name",
    c.category_status AS "카테고리 사용여부"
FROM category c
WHERE c.category_id = 14
ORDER BY c.category_id ASC;

-- 활성화된 카테고리만 조회
SELECT 
    c.category_id   AS "카테고리 id",
    c.category_type AS "카테고리 타입",
    c.category_name AS "카테고리 name",
    c.category_status AS "카테고리 사용여부"
FROM category c
WHERE c.category_status = 'Y'
ORDER BY c.category_id ASC;