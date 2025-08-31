-- AUC_SRC_004 거래내역 조회
-- 거래내역 전체 조회
SELECT
    ai.auction_id      AS "경매ID",
    ab.created_at      AS "낙찰 시각",
    ai.category_id     AS "카테고리ID",
    c.category_name    AS "카테고리 이름",
    ai.auction_title   AS "경매 제목",
    us.user_name       AS "판매자",
    ub.user_name       AS "구매자",
    ab.bid_amount      AS "낙찰가",
    ab.success_status  AS "낙찰여부(Y/N)"
FROM auction_item ai
JOIN auction_bid   ab ON ab.auction_id = ai.auction_id                 
JOIN category      c  ON c.category_id = ai.category_id
JOIN `user`        us ON us.user_id = ai.user_id     
JOIN `user`        ub ON ub.user_id = ab.user_id     
ORDER BY ab.created_at DESC
LIMIT 10;

-- ------------------------------------------------------------------
-- AUC_SRC_005 거래내역 검색
-- 카테고리 선택으로 조회
DELIMITER //

CREATE PROCEDURE category_bid_search (
    IN p_category_id INT 
)
BEGIN
    SELECT
        ai.auction_id,
        ai.user_id,
        ai.category_id,
        ai.auction_title,
        ai.auction_content,
        ai.created_at,
        ab.bid_id,
        ab.bid_amount,
        ab.auction_id	
    FROM auction_item ai
    JOIN auction_bid ab 
        ON ai.auction_id = ab.auction_id
    WHERE ai.category_id = p_category_id
    ORDER BY ai.created_at DESC
	 LIMIT 10;
END //

DELIMITER ;

CALL category_bid_search(1);

-- 키워드로 검색
DELIMITER //
CREATE PROCEDURE keyword_bid_search(
	IN p_keyword VARCHAR(100)
)
BEGIN
	SELECT
        ai.auction_id,
        ai.user_id,
        ai.category_id,
        ai.auction_title,
        ai.auction_content,
        ai.created_at,
        ab.bid_id,
        ab.bid_amount,
        ab.auction_id	
    FROM auction_item ai
    JOIN auction_bid ab 
        ON ai.auction_id = ab.auction_id
   WHERE auction_title LIKE CONCAT("%", p_keyword, "%")
   ORDER BY created_at DESC
	LIMIT 10;
END //
DELIMITER ;

CALL keyword_bid_search("아이폰");

-- ----------------------------------------------------------
-- AUC_SRC_006 경매물품 삭제
-- auction_id = 4인 경우로 test

-- 입찰 기록을 지워줌
DELETE FROM auction_bid
WHERE bid_id = 4;


DELIMITER //

CREATE PROCEDURE deactive_auction (
    IN p_auction_id INT
)
BEGIN
    DECLARE v_bid_count INT;

    -- 경매 입찰 수를 확인
    SELECT COUNT(*)
    INTO v_bid_count
    FROM auction_bid
    WHERE bid_id = p_auction_id;

    -- 2. 입찰이 없을 경우에만 비활성화
    IF v_bid_count = 0 THEN
        UPDATE auction_item
        SET posting_status = 'N'
        WHERE auction_id = p_auction_id;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '오류';
    END IF;

END //

DELIMITER ;

call deactive_auction(4);