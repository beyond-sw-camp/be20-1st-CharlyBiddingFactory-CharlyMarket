-- 경매에 대한 한건의 알림 발송
INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id)
SELECT 'Y', 1, 1, 1
FROM alarm_template t
WHERE t.category_id = 15 AND t.alarm_status = 'Y'
ORDER BY t.alarm_id DESC
LIMIT 1;

-- 경매에 대한 다건의 알림 발송 (즐겨찾기 사용자 전체)
INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id)
SELECT 'Y', f.user_id,1, f.auction_id
FROM favorite f
WHERE f.auction_id=1;

-- 검증
-- 카테고리별 검색(다중 선택 가능)
SELECT 
    CASE al.category_id
        WHEN 14 THEN CONCAT('[회원알림] ', u.user_name, '님',' ',  al.alarm_content, ' (', a.created_at, ')')
        WHEN 15 THEN CONCAT('[경매알림] ', u.user_name, '님 ', ac.auction_title, ' ', al.alarm_content, ' (', a.created_at, ')')
        WHEN 16 THEN CONCAT('[배송알림] ', u.user_name, '님 ', ac.auction_title, ' ', al.alarm_content, ' (', a.created_at, ')')
    END AS "알림 메시지"
    
FROM alarm_box a
JOIN auction_item ac   ON a.auction_id = ac.auction_id
JOIN `user` u          ON a.user_id = u.user_id
JOIN alarm_template al ON a.alarm_id = al.alarm_id
WHERE a.user_id = 1
  AND ac.auction_title LIKE CONCAT("%","아이폰","%")   -- 물품 제목 조건
  AND al.category_id IN(14)                              -- 회원 : 14, 경매 : 15, 배송 : 16
ORDER BY a.alarm_box_id DESC;

-- 검증
-- 카테고리 전체 검색 가능
SELECT 
    CASE al.category_id
        WHEN 14 THEN CONCAT('[회원알림] ', u.user_name, '님',' ',  al.alarm_content, ' (', a.created_at, ')')
        WHEN 15 THEN CONCAT('[경매알림] ', u.user_name, '님 ', ac.auction_title, ' ', al.alarm_content, ' (', a.created_at, ')')
        WHEN 16 THEN CONCAT('[배송알림] ', u.user_name, '님 ', ac.auction_title, ' ', al.alarm_content, ' (', a.created_at, ')')
    END AS "알림 메시지"
    
FROM alarm_box a
JOIN auction_item ac   ON a.auction_id = ac.auction_id
JOIN `user` u          ON a.user_id = u.user_id
JOIN alarm_template al ON a.alarm_id = al.alarm_id
WHERE a.user_id = 1
  AND ac.auction_title LIKE CONCAT("%","아이폰","%")   -- 물품 제목 조건           