-- USR_SRC_002
-- 회원정보 조회
SELECT
		a.id, 
		a.user_password, 
		a.user_name, 
		a.user_phone, 
		a.user_email, 
		a.user_nickname,
		g.grade_name,
		c.auction_title,
		CASE 
        WHEN b.success_status = 'Y' THEN '낙찰'
        ELSE '참여'
    	END AS auction_list
		FROM user a
	 JOIN auction_bid b USING(user_id)
	 JOIN auction_item c USING(auction_id)
	 JOIN grade g USING(grade_id)
	WHERE b.user_id = '1';