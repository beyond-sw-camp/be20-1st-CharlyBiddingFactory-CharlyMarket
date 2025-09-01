-- USR_ANT_003
-- 회원 계좌 삭제
-- 관리자는 은행명과 계좌번호를 입력해 삭제할 수 있다.
DELETE FROM account
WHERE bank_name = '신한은행'
  AND account_no = '11012345678'
  AND user_id = 2;
 

-- 사용자는 이름명, 은행명, 계좌번호를 입력해야만 계좌를 삭제할 수 있다.
DELETE a
	FROM account a
	JOIN user u ON a.user_id = u.user_id
	WHERE a.bank_name = '카카오뱅크'
	  AND a.account_no = '1234567890'
	  AND u.user_name = '홍길동';