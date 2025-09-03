INSERT INTO review 
(
	review_star, 
	review_content, 
	review_status, 
	reviewer_id, 
	reviewee_id, 
	auction_id
) VALUES
(
	5,
	'상품 상태가 좋아요',
	'Y',
	2,
	3,
	1
);

INSERT INTO file
(
	auction_id,
	file_path,
	file_name,
	file_type,
	review_id
) VALUES 
(
	1,
	'/home/charly/image.png',
	'image',
	'png',
	1
);