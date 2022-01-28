-- INITIAL INSERT
-- 1. hr schema
INSERT INTO hr.positions (name) VALUES
	('intern'),
	('manager'),
	('director');
	
INSERT INTO hr.employees (first_name, last_name, salary_cent, position_id, is_active) VALUES
	('Joe', 'Dow', 40000000, 1, TRUE),
	('Adler', 'Smith', 120000000, 2, TRUE),
	('Dan', 'Johnson', 50000000, 1, TRUE),
	('Gordon', 'Brown', 110000000, 2, TRUE),
	('Roben', 'Williams', 200000000, 3, TRUE),
	('Antoine', 'Davis', 90000000, 2, TRUE),
	('Richard', 'Scott', 200000000, 3, False);
	
	
-- 2. operations schema
INSERT INTO operations.operations_type (name) VALUES
	('selected'),
	('estimated'),
	('bought'),
	('rejected'),
	('wait'),
	('maintenance'),
	('sale'),
	('reserved'),
	('sold'),
	('depricated'),
	('test drive');


-- 3. finance schema


-- 4. sales schema
-- 4.1. clients
INSERT INTO sales.clients (first_name, last_name, phone, email) VALUES
	('Earl', 'Hilton', '+1 505 545-0618', 'earl.hilton@famousbox.com'),
	('Lucy', 'Hartley', '+501 625-7114', 'lucy.hartley@famousbox.com'),
	('Ivan', 'Borisov', '+7 905 112-9363', 'ivan.borisov@otherbox.ru'),
	('Gregory', 'Kan', '+32 472 60-5213', 'gregory.kan@famousbox.com'),
	('Juno', 'Ellis', '+973 38 08-1918', 'juno.ellis@famousbox.com'),
	('Cooper', 'Stevenson', '+880 370 624-8802', 'cooper.stevenson@famousbox.com'),
	('Uma', 'Dotson', '+1 242-449-1440', 'uma.dorson@famousbox.com'),
	('Dotty', 'Mahoney', '+994 55-938-9633', 'dotty.mahoney@famousbox.com'),
	('Millie-Rose', 'Forbes', '+297 770 8035', 'millie_rose.forbes@famousbox.com'),
	('Riachel', 'Rose', '+61 49 303-0610', 'riachel.rose@famousbox.com');
	

-- 4.2. cars
INSERT INTO sales.car_types (brand, model, engine_type) VALUES
	('nissan', 'mirai', 'electric'),
	('nissan', 'mirai', 'h2'),
	('bmw', 'x5', 'diesel'),
	('bmw', 'x5', 'gasoline'),
	('mercedes', 'e200', 'gasoline'),
	('mercedes', 'g550', 'diesel'),
	('tesla', 'model s', 'electric'),
	('ford', 'focus', 'gas'),
	('ford', 'focus', 'lng'),
	('ford', 'mondeo', 'gasoline');


INSERT INTO sales.car_market (client_id, car_type_id, description, photo_folder, price_cents) VALUES
	(1, 3, '{"body": "SUV", "transmission": "6-speed manual", "color": "#FFFFFF", "defects": "dent on the left door"}'::jsonb, 'https://www.bucket.com/id0000001', 40000000),
	(1, 1, '{"body": "sedan", "transmission": "5-speed auto", "color": "#F0F8FF", "toning": true}'::jsonb, 'https://www.bucket.com/id0000002', 30000000),
	(3, 9, '{"body": "hatchback", "color": "#FF0000"}'::jsonb, 'https://www.bucket.com/id0000004', 60000000),
	(7, 8, '{"transmission": "6-speed auto", "color": "#F0F8FF"}'::jsonb, 'https://www.bucket.com/id0000006', 30000000),
	(5, 7, '{}'::jsonb, 'https://www.bucket.com/id0000007', 80000000),
	(6, 3, '{"body": "SUV", "transmission": "5-speed manual", "color": "#F0F8FF", "defects": "without backdoor"}'::jsonb, 'https://www.bucket.com/id0000008', 10000000),
	(2, 4, '{"body": "SUV", "transmission": "6-speed manual", "color": "#7CFC00"}'::jsonb, 'https://www.bucket.com/id0000009', 45000000);

INSERT INTO sales.services (name) VALUES
	('test drive'),
	('buy'),
	('sell');
	
-- X. Additional commands
-- To clean table with foregin key - TRUNCATE TABLE hr.positions RESTART IDENTITY CASCADE;
-- restart sequence - ALTER SEQUENCE sales.clients_id_seq RESTART WITH 1;;