-- 푸시 알림 내용, 활성 비활성화 수정
UPDATE alarm_template
SET alarm_content = '경매 시작 알림이 수정되었습니다.',
    alarm_status  = 'Y'
WHERE alarm_id = 1;              