-- 한 번만: 이벤트 스케줄러 ON (권한 필요)
SET GLOBAL event_scheduler = ON;

-- 매 1분마다 종료 경매 정산
DROP EVENT IF EXISTS ev_close_auctions;
CREATE EVENT ev_close_auctions
    ON SCHEDULE EVERY 1 MINUTE
    DO
      CALL sp_close_auctions();