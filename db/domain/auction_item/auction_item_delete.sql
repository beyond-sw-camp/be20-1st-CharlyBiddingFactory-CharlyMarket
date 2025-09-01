-- auction_id = 4인 경우로 test
-- auction_id = 4인 경우로 test
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
    WHERE auction_id = p_auction_id;

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
