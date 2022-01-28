-- UPDATE INSERT
-- 1. sales.reviewed_cars
-- Cars in review
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(1, 2, SELECT id FROM operations.operations_type WHERE name = 'selected');
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(3, 4, SELECT id FROM operations.operations_type WHERE name = 'selected');
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(4, 6, SELECT id FROM operations.operations_type WHERE name = 'selected');
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(5, 7, SELECT id FROM operations.operations_type WHERE name = 'selected');
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(6, 4, SELECT id FROM operations.operations_type WHERE name = 'selected');
INSERT INTO sales.reviewed_cars (car_id, employee_id, status_id) VALUES 
	(7, 4, SELECT id FROM operations.operations_type WHERE name = 'selected');

-- Estimated cars
UPDATE sales.reviewed_cars SET estimated_cost_cent = 39000000 WHERE car_id = 1;
UPDATE sales.reviewed_cars SET estimated_price_cent = 4100000 WHERE car_id = 1;
UPDATE sales.reviewed_cars SET estimated_price_cent = 41500000 WHERE car_id = 1;

UPDATE sales.reviewed_cars SET estimated_cost_cent = 30000000 WHERE car_id = 3;
UPDATE sales.reviewed_cars SET estimated_price_cent = 32000000 WHERE car_id = 3;

UPDATE sales.reviewed_cars SET estimated_cost_cent = 30000000, estimated_price_cent = 31300000 WHERE car_id = 4;

UPDATE sales.reviewed_cars SET estimated_cost_cent = 78000000 WHERE car_id = 5;

UPDATE sales.reviewed_cars SET estimated_price_cent = 9500000 WHERE car_id = 6;
UPDATE sales.reviewed_cars SET estimated_cost_cent = 10000000 WHERE car_id = 6;

-- Rejected cars
UPDATE sales.reviewed_cars SET status_id = (SELECT id FROM operations.operations_type WHERE name = 'rejected') WHERE car_id = 4;
UPDATE sales.reviewed_cars SET status_id = (SELECT id FROM operations.operations_type WHERE name = 'rejected') WHERE estimated_profit_cent <= 0;

-- Bought cars as one transaction
DO $$ BEGIN
	INSERT INTO sales.carpool (car_id, employee_id, purchase_price_cent) VALUES 
		(1, 2, 39000000);
	-- Save contract
	INSERT INTO finance.contracts (employee_id, client_id, car_id, profit) VALUES
		(2, (SELECT client_id FROM sales.car_market WHERE id = 1), 1, -39000000);
	-- Update statistical table
	PERFORM sales.add_client_ordered_services(client_name := 'Earl'::VARCHAR(20),
											  client_surname := 'Hilton'::VARCHAR(40),
											  client_phone := '+1 505 545-0618'::phone_number,
											  service_name := 'sell'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another car
DO $$ BEGIN
	INSERT INTO sales.carpool (car_id, employee_id, purchase_price_cent) VALUES 
		(3, 2, 29500000);
	-- Save contract
	INSERT INTO finance.contracts (employee_id, client_id, car_id, profit) VALUES
		(2, (SELECT client_id FROM sales.car_market WHERE id = 3), 3, -29500000);
	-- Update statistical table
	PERFORM sales.add_client_ordered_services(client_name := 'Ivan'::VARCHAR(20),
											  client_surname := 'Borisov'::VARCHAR(40),
											  client_phone := '+7 905 112-9363'::phone_number,
											  service_name := 'sell'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another car
DO $$ BEGIN
	INSERT INTO sales.carpool (car_id, employee_id, purchase_price_cent) VALUES 
		(4, 4, 30000000);
	-- Save contract
	INSERT INTO finance.contracts (employee_id, client_id, car_id, profit) VALUES
		(4, (SELECT client_id FROM sales.car_market WHERE id = 4), 4, -30000000);
	-- Update statistical table
	PERFORM sales.add_client_ordered_services(client_name := 'Uma'::VARCHAR(20),
											  client_surname := 'Dotson'::VARCHAR(40),
											  client_phone := '+1 242-449-1440'::phone_number,
											  service_name := 'sell'::VARCHAR(40));
END $$ LANGUAGE plpgsql;

-- Sent cars to service. P.S. service_car_id - external id from service station
UPDATE sales.carpool SET status = 'maintenance', service_car_id = 99 WHERE car_id = 1;
UPDATE sales.carpool SET status = 'maintenance', service_car_id = 101 WHERE car_id = 3;

-- Get cars from services
UPDATE sales.carpool SET 
	status = 'wait',
	description = (SELECT description - 'defects' FROM sales.car_market WHERE id = 1), -- Copy descriotion without defects - let's say defects was removed after service,
	photo_folder = 'https://www.bucket.com/id0000010',
	service_cost_cent = 1000000
WHERE car_id = 1;

-- Set sell status 
UPDATE sales.carpool SET 
	status = 'sale',
	price_cent = ((SELECT service_cost_cent FROM sales.carpool WHERE car_id = 1) + (SELECT purchase_price_cent FROM sales.carpool WHERE car_id = 1)) * 1.15
WHERE car_id = 1;
-- Another car
UPDATE sales.carpool SET 
	status = 'sale',
	description = (SELECT (SELECT description FROM sales.car_market WHERE id = 3) || '{"toning": true}'::jsonb)::jsonb,
	photo_folder = (SELECT photo_folder FROM sales.car_market WHERE id = 3)::url,
	service_cost_cent = 0,
	price_cent = (SELECT estimated_price_cent FROM sales.reviewed_cars WHERE car_id = 3)::integer
WHERE car_id = 3;

-- Sold cars
DO $$ BEGIN
	UPDATE sales.carpool SET status = 'sold' WHERE car_id = 3;
	-- Save contract
	INSERT INTO finance.contracts (employee_id, client_id, car_id, profit) VALUES
		(6, 8, 3, (SELECT price_cent FROM sales.carpool WHERE car_id = 3));
	-- Update statistical table
	PERFORM sales.add_client_ordered_services(client_name := 'Dotty'::VARCHAR(20),
											  client_surname := 'Mahoney'::VARCHAR(40),
											  client_phone := '+994 55-938-9633'::phone_number,
											  service_name := 'buy'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
	
-- Test drive car
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time) VALUES
		(1, 7, 9, '2021-11-23 14:00:00+01');
	UPDATE sales.test_drive SET end_time = '2021-11-23 15:30:00+01' WHERE id = 1;
	PERFORM sales.add_client_ordered_services(client_name := 'Millie-Rose'::VARCHAR(20),
											  client_surname := 'Forbes'::VARCHAR(40),
											  client_phone := '+297 770 8035'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another test drive
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time) VALUES
		(3, 2, 7, '2021-11-25 09:00:00+01');
	UPDATE sales.test_drive SET end_time = '2021-11-25 10:30:00+01' WHERE id = 2;
	PERFORM sales.add_client_ordered_services(client_name := 'Uma'::VARCHAR(20),
											  client_surname := 'Dotson'::VARCHAR(40),
											  client_phone := '+1 242-449-1440'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another test drive
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time) VALUES
		(3, 6, 8, '2021-11-26 10:00:00+01');
	UPDATE sales.test_drive SET end_time = '2021-11-26 10:30:00+01' WHERE id = 3;
	PERFORM sales.add_client_ordered_services(client_name := 'Dotty'::VARCHAR(20),
											  client_surname := 'Mahoney'::VARCHAR(40),
											  client_phone := '+994 55-938-9633'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another test drive
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time) VALUES
		(3, 6, 8, '2021-11-26 14:00:00+01');
	UPDATE sales.test_drive SET end_time = '2021-11-26 14:30:00+01' WHERE id = 4;
	PERFORM sales.add_client_ordered_services(client_name := 'Dotty'::VARCHAR(20),
											  client_surname := 'Mahoney'::VARCHAR(40),
											  client_phone := '+994 55-938-9633'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another test drive
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time, end_time) VALUES
		(1, 3, 2, '2021-11-27 14:00:00+01', '2021-11-27 15:00:00+01');
	PERFORM sales.add_client_ordered_services(client_name := 'Lucy'::VARCHAR(20),
											  client_surname := 'Hartley'::VARCHAR(40),
											  client_phone := '+501 625-7114'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
-- Another test drive
DO $$ BEGIN
	INSERT INTO sales.test_drive (car_id, employee_id, client_id, start_time) VALUES
		(1, 3, 10, '2025-11-30 14:00:00+01');
	PERFORM sales.add_client_ordered_services(client_name := 'Riachel'::VARCHAR(20),
											  client_surname := 'Rose'::VARCHAR(40),
											  client_phone := '+61 49 303-0610'::phone_number,
											  service_name := 'test drive'::VARCHAR(40));
END $$ LANGUAGE plpgsql;
