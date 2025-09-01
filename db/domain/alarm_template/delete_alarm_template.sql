-- 알림 1건 비활성화
  UPDATE alarm_template
SET alarm_status = 'N'   -- 'Y' 사용 / 'N' 미사용(삭제 처리)
WHERE alarm_id = 1;      -- 삭제 처리할 알람 id

-- 카테고리 단위로 여러 건 비활성화
UPDATE alarm_template
SET alarm_status = 'N'
WHERE category_id = 15
  AND alarm_status = 'Y';