-- 운송장 번호 등록 및 상태 변경
UPDATE delivery 
	SET delivery_no = '5231582571234',
		  delivery_status = 'I'
  WHERE delivery_id = 1;
