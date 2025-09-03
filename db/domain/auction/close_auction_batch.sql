USE charly_market;
DROP PROCEDURE IF EXISTS sp_close_auctions;

DELIMITER //

CREATE PROCEDURE sp_close_auctions()
BEGIN
    DECLARE v_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT auction_id
          FROM auction_item
         WHERE auction_end_time <= NOW(6)
            AND (
			       bid_status = 'B'
			    OR bid_status IS NULL
			)
         ORDER BY auction_end_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL sp_close_one_auction(v_id);
    END LOOP;
    CLOSE cur;
END;
//
DELIMITER ;
