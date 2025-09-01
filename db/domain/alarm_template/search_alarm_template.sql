-- 전체 알람 목록 조회
SELECT 
    a.alarm_id      AS "알람 id",
    a.alarm_content AS "알림 내용",
    a.alarm_status  AS "알림 활성화 여부",
    a.category_id   AS "카테고리 id",
    c.category_name AS "카테고리 name"
FROM alarm_template a
JOIN category c ON c.category_id = a.category_id
ORDER BY a.alarm_id ASC;

-- 카테고리별 알람 목록 조회
SELECT 
    a.alarm_id      AS "알람 id",
    a.alarm_content AS "알림 내용",
    a.alarm_status  AS "알림 활성화 여부",
    a.category_id   AS "카테고리 id",
    c.category_name AS "카테고리 name"
FROM alarm_template a
JOIN category c ON c.category_id = a.category_id
WHERE a.category_id = 14
ORDER BY a.alarm_id ASC;

-- 알람 status 활성화 여부별 조회
SELECT 
    a.alarm_id      AS "알람 id",
    a.alarm_content AS "알림 내용",
    a.alarm_status  AS "알림 활성화 여부",
    a.category_id   AS "카테고리 id",
    c.category_name AS "카테고리 name"
FROM alarm_template a
JOIN category c ON c.category_id = a.category_id
WHERE a.category_id in(14,15,16)
  AND a.alarm_status = 'N'