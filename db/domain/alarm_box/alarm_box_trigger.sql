-- 회원가입
DROP TRIGGER IF EXISTS trg_user_after_insert;
DELIMITER //
CREATE TRIGGER trg_user_after_insert
AFTER INSERT ON `user`
FOR EACH ROW
BEGIN
  CALL send_alarm_kw(NEW.user_id, NULL, 14, '회원가입', NULL);
END //
DELIMITER ;

-- 비밀번호 변경
DROP TRIGGER IF EXISTS trg_user_pw_after_update;
DELIMITER //
CREATE TRIGGER trg_user_pw_after_update
AFTER UPDATE ON `user`
FOR EACH ROW
BEGIN
  IF NEW.user_password <> OLD.user_password THEN
    CALL send_alarm_kw(NEW.user_id, NULL, 14, '비밀번호', NULL);
  END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_user_email_after_update;
DELIMITER //
CREATE TRIGGER trg_user_email_after_update
AFTER UPDATE ON `user`
FOR EACH ROW
BEGIN
  IF NEW.user_email<> OLD.user_email THEN
    CALL send_alarm_kw(NEW.user_id, NULL, 14, '이메일', NULL);
  END IF;
END //
DELIMITER ;

-- 경매 시작
DROP TRIGGER IF EXISTS trg_bid_first_insert;
DELIMITER //
CREATE TRIGGER trg_bid_first_insert
AFTER UPDATE ON auction_item
FOR EACH ROW
BEGIN
	IF NEW.bid_status='B' THEN
  	CALL send_alarm_kw(NEW.user_id, NEW.auction_id, 15, '경매가 시작', NULL);
  END IF;
END //
DELIMITER ;

-- 상위 입찰
-- 새로운 입찰자 발생 시 이전 입찰자에게 알림 발송
DROP TRIGGER IF EXISTS trg_bid_up_insert;
DELIMITER //
CREATE TRIGGER trg_bid_up_insert
AFTER INSERT ON auction_bid
FOR EACH ROW
BEGIN
    DECLARE old_user_id INT;

    -- 방금 들어온 사람 제외하고, 같은 물품에서 가장 높은 입찰자 찾기
    SELECT user_id
      INTO old_user_id
    FROM auction_bid
    WHERE auction_id = NEW.auction_id
      AND bid_id <> NEW.bid_id
    ORDER BY bid_amount DESC, created_at DESC
    LIMIT 1;

    -- 이전 최고 입찰자가 존재한다면 알림 전송
    IF old_user_id IS NOT NULL THEN
        CALL send_alarm_kw(old_user_id, NEW.auction_id, 15, '상위 입찰', NULL);
    END IF;
END //
DELIMITER ;


-- 낙찰(success_status = 'Y')
-- 낙찰 발생 시 판매자와 최종 입찰자에게 알림 발송
DROP TRIGGER IF EXISTS trg_bid_after_update;
DELIMITER //
CREATE TRIGGER trg_bid_after_update
AFTER UPDATE ON auction_bid
FOR EACH ROW
BEGIN
	DECLARE auction_user_id INT;

  IF NEW.success_status = 'Y' AND (OLD.success_status IS NULL OR OLD.success_status <> 'Y') THEN
  
  	SELECT ai.user_id INTO auction_user_id
	  FROM auction_bid ab
	  JOIN auction_item ai ON ab.auction_id=ai.auction_id
	 WHERE ab.auction_id=NEW.auction_id
	 LIMIT 1; 
    CALL send_alarm_kw(NEW.user_id, NEW.auction_id, 15, '낙찰', NULL); 
   CALL send_alarm_kw(auction_user_id, NEW.auction_id, 15, '낙찰', NULL);
  END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS trg_delivery_after_update;
DELIMITER //
CREATE TRIGGER trg_delivery_after_update
AFTER UPDATE ON delivery
FOR EACH ROW
BEGIN
  -- 운송장 번호 입력/변경
  IF NEW.delivery_no IS NOT NULL 
     AND (OLD.delivery_no IS NULL OR NEW.delivery_no <> OLD.delivery_no) THEN
    CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '운송장 번호', NULL);
  END IF;

  -- 배송지 주소 입력/변경
  IF NEW.delivery_address IS NOT NULL 
     AND (OLD.delivery_address IS NULL OR NEW.delivery_address <> OLD.delivery_address) THEN
    CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '배송지', NULL);
  END IF;

  -- 상태 변경
  IF NEW.delivery_status <> OLD.delivery_status THEN
    IF NEW.delivery_status = 'I' THEN
      CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '배송이 시작', NULL);
    ELSEIF NEW.delivery_status = 'S' THEN
      CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '배송이 완료', NULL);
    ELSEIF NEW.delivery_status = 'R' THEN
      CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '반송', NULL);
    ELSE
      CALL send_alarm_kw(NEW.receiver_user_id, NEW.auction_id, 16, '배송', NULL);
    END IF;
  END IF;
END //
DELIMITER ;
