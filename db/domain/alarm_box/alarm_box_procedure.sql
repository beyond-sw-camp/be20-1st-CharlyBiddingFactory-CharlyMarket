DROP PROCEDURE IF EXISTS send_alarm_kw;
DELIMITER //
CREATE PROCEDURE send_alarm_kw(
    IN p_user_id INT,
    IN p_auction_id INT,        -- 회원(14)일 때 NULL/0 가능(아래 보정)
    IN p_category_id INT,       -- 14=회원, 15=경매, 16=배송
    IN p_keyword VARCHAR(100),  -- 템플릿 키워드(예: 회원가입/비밀번호/경매가 시작/새로운 입찰/낙찰/배송/완료/운송장 번호)
    IN p_extra VARCHAR(200)     -- 추가 설명(옵션)
)
BEGIN
  main: BEGIN
    DECLARE v_alarm_id   INT;
    DECLARE v_template   VARCHAR(999);
    DECLARE v_msg        VARCHAR(1000);
    DECLARE v_auction_id INT;

   -- 회원(14) 보정: alarm_box.auction_id NOT NULL 대응 alarm box 테이블auction_id 행 널 필요
    IF (p_category_id = 14) AND (p_auction_id IS NULL OR p_auction_id = 0) THEN
        SELECT MIN(auction_id) INTO v_auction_id FROM auction_item;
        IF v_auction_id IS NULL THEN LEAVE main; END IF;
    ELSE
        SET v_auction_id = p_auction_id;
    END IF;

    -- 2) 템플릿 선택: 카테고리+키워드 우선 → 없으면 최신 활성 
    SET v_alarm_id = NULL;
    SELECT alarm_id, alarm_content
      INTO v_alarm_id, v_template
    FROM alarm_template
    WHERE category_id = p_category_id
      AND alarm_status = 'Y'
      AND alarm_content LIKE CONCAT('%', p_keyword, '%')
    ORDER BY alarm_id DESC
    LIMIT 1;

    IF v_alarm_id IS NULL THEN
      SELECT alarm_id, alarm_content
        INTO v_alarm_id, v_template
      FROM alarm_template
      WHERE category_id = p_category_id
        AND alarm_status = 'Y'
      ORDER BY alarm_id DESC
      LIMIT 1;
    END IF;

    IF v_alarm_id IS NULL THEN LEAVE main; END IF;

    -- 3) 최종 문구 조립 
    SELECT
      CASE p_category_id
        WHEN 14 THEN CONCAT('[회원알림] ', u.user_name, '님 ',  v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        WHEN 15 THEN CONCAT('[경매알림] ', u.user_name, '님 [', COALESCE(ai.auction_title,''), '] ', v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        WHEN 16 THEN CONCAT('[배송알림] ', u.user_name, '님 [', COALESCE(ai.auction_title,''), '] ', v_template, ' (', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), ')')
        ELSE v_template
      END
    INTO v_msg
    FROM `user` u
    LEFT JOIN auction_item ai ON ai.auction_id = v_auction_id
    WHERE u.user_id = p_user_id;

    -- 4) alarm_box 저장 
    INSERT INTO alarm_box (alarm_check, user_id, alarm_id, auction_id, alarm_content)
    VALUES ('N', p_user_id, v_alarm_id, v_auction_id, v_msg);
  END main;
END //
DELIMITER ;

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
