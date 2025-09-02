-- 권한 부여 (GRANT)
-- charlymarket 계정에 따라 권한 부여
-- admin,user 로 계정을 나누어 테이블마다 권한을 설정할 것이다
CREATE user 'ADMIN'@'%' IDENTIFIED BY 'admin';
CREATE user 'USER'@'%'IDENTIFIED BY 'user';

-- 현재 charlymarket 에 모든 계정의 권한 확인
SELECT * 
FROM information_schema.SCHEMA_PRIVILEGES
WHERE TABLE_SCHEMA = 'charlymarket';

SHOW GRANTS FOR 'ADMIN'@'%';
SHOW GRANTS FOR 'USER'@'%';

-- 관리자 (ADMIN) 은 모든 권한이 가능하도록 설정
GRANT ALL PRIVILEGES ON charlymarket.* TO 'ADMIN'@'%';

-- USER
-- 테이블 마다 user의 권한을 다르게 줄 것 이다.
-- charlymarket은 delete 방식이 soft delete 여서 대부분 delete의 권한은 주지 않는다

-- 모든 프로시져 권한
GRANT EXECUTE ON charlymarket.* TO 'USER'@'%';

-- grade : select만 가능
GRANT SELECT 
ON charlymarket.grade 
TO 'USER'@'%';


-- user : select , insert, update
GRANT SELECT, INSERT, UPDATE 
ON charlymarket.user 
TO 'USER'@'%';


-- notice : select 
GRANT SELECT, INSERT, UPDATE 
ON charlymarket.notice
TO 'USER'@'%';


-- account : select , insert , delete
GRANT SELECT, INSERT, DELETE 
ON charlymarket.account
TO 'USER'@'%';


-- payment_log : select , insert
GRANT SELECT, INSERT 
ON charlymarket.payment_log
TO 'USER'@'%';



-- inquiry : select , insert
GRANT SELECT, INSERT 
ON charlymarket.inquiry
TO 'USER'@'%';


-- category : select
GRANT SELECT 
ON charlymarket.category
TO 'USER'@'%';


-- auction_item : select , insert , update
GRANT SELECT, INSERT, UPDATE 
ON charlymarket.auction_item
TO 'USER'@'%';


-- alarm_template : none


-- alarm_box : select , update
GRANT SELECT, UPDATE 
ON charlymarket.alarm_box
TO 'USER'@'%';


-- report : select , insert , update
GRANT SELECT, INSERT , UPDATE  
ON charlymarket.report
TO 'USER'@'%';



-- delivery : select , insert , update
GRANT SELECT, INSERT , UPDATE 
ON charlymarket.delivery
TO 'USER'@'%';


-- auction_bid : select, insert, update
GRANT SELECT, INSERT, UPDATE  
ON charlymarket.auction_bid
TO 'USER'@'%';


-- point_log : select, insert
GRANT SELECT, INSERT  
ON charlymarket.point_log
TO 'USER'@'%';


-- review : select, insert, update
GRANT SELECT, INSERT, UPDATE  
ON charlymarket.review
TO 'USER'@'%';


-- file : select, insert, update
GRANT SELECT, INSERT, UPDATE  
ON charlymarket.file
TO 'USER'@'%';


-- favorite : select , insert , delete
GRANT SELECT, INSERT, delete  
ON charlymarket.favorite
TO 'USER'@'%';

