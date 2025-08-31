-- USR_ANT_001
-- 회원 계좌 등록
INSERT INTO account (bank_name, account_no, bank_owner, user_id)
VALUES ('카카오뱅크', '123-456-7890', '홍길동', 1);

-- 회원의 이름과 동일해야 계좌번호를 추가 할 수 있다.
INSERT INTO account (bank_name, account_no, bank_owner, user_id)
SELECT '카카오뱅크', '1234567890', u.user_name, u.user_id
FROM user u
WHERE u.user_id = 1
  AND u.user_name = '홍길동';