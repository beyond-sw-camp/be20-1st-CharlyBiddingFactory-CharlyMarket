-- 배송지 입력 및 상태 변경
UPDATE delivery 
	SET delivery_address = '서울 광진구 긴고랑로4길 13',
		  delivery_status = 'E',
          registered_at = NOW()
  WHERE delivery_id = 1;