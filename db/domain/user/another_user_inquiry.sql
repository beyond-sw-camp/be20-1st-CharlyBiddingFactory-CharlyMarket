-- USR_PRF_001
-- 프로필 조회
-- 다른 user의 기본 정보 조회
SELECT 
		id,
		user_name,
		grade_id,
	FROM user
	WHERE user_id = 2;

-- 거래 품목 조회
SELECT 
    ai.auction_title,
    ab.bid_amount,
    ab.success_status AS bid_status
	FROM auction_item ai
	LEFT JOIN auction_bid ab 
	    ON ai.auction_id = ab.auction_id
	WHERE ai.user_id = 2;                 -- 조회할 회원 ID


-- 거래 후기 조회
SELECT 
    r.review_star,
    r.review_content,
    r.created_at AS review_date
	FROM review r
	WHERE r.reviewee_id = 2;   -- 조회할 회원 ID