-- USR_ANT_002
-- 회원 계좌 조회
-- 관리자는 회원 ID로 계좌 정보를 조회할 수 있다.
SELECT 
	    bank_name,
	    account_no,
	    bank_owner,
	FROM account
	WHERE user_id = 2;