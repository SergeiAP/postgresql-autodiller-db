-- 1. Function to observe car test drives
CREATE or REPLACE FUNCTION sales.observe_car_test_drives(car_search int,
														 time_from timestamp(0) with time zone DEFAULT NOW()
														) RETURNS TABLE (car_id INT,
																		 employee_id SMALLINT,
																		 client_id INT,
																		 employee_surname VARCHAR(40),
																		 client_surname VARCHAR(40),
																		 start_time timestamp(0) with time zone,
																		 end_time timestamp(0) with time zone,
																		 duration_mins SMALLINT)
AS
$$
BEGIN
	RETURN QUERY
	SELECT sales.test_drive.car_id,
		   sales.test_drive.employee_id,
		   sales.test_drive.client_id,
		   hr.employees.last_name AS employee_surname,
		   sales.clients.last_name AS client_surname,
		   sales.test_drive.start_time,
		   sales.test_drive.end_time,
		   sales.test_drive.duration_mins
	FROM sales.test_drive
	LEFT JOIN hr.employees ON sales.test_drive.employee_id = hr.employees.id
	LEFT JOIN sales.clients ON sales.test_drive.client_id = sales.clients.id
	WHERE sales.test_drive.car_id = car_search AND sales.test_drive.start_time >= time_from
	ORDER BY sales.test_drive.start_time;
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION sales.observe_car_test_drives IS 'Function to observe car test drives';


-- 2. Function to observe employee test drives
CREATE or REPLACE FUNCTION sales.observe_employee_test_drives(employee_search_name VARCHAR(20),
															  employee_search_surname VARCHAR(40),
															  time_from timestamp(0) with time zone DEFAULT NOW()
															 ) RETURNS TABLE (car_id INT,
																			  employee_id SMALLINT,
																			  client_id INT,
																			  employee_surname VARCHAR(40),
																			  client_surname VARCHAR(40),
																			  start_time timestamp(0) with time zone,
																			  end_time timestamp(0) with time zone,
																			  duration_mins SMALLINT)
AS
$$
BEGIN
	RETURN QUERY
	SELECT sales.test_drive.car_id,
		   sales.test_drive.employee_id,
		   sales.test_drive.client_id,
		   hr.employees.last_name AS employee_surname,
		   sales.clients.last_name AS client_surname,
		   sales.test_drive.start_time,
		   sales.test_drive.end_time,
		   sales.test_drive.duration_mins
	FROM sales.test_drive
	LEFT JOIN hr.employees ON sales.test_drive.employee_id = hr.employees.id
	LEFT JOIN sales.clients ON sales.test_drive.client_id = sales.clients.id
	WHERE sales.test_drive.employee_id IN (SELECT id FROM hr.employees WHERE hr.employees.first_name = employee_search_name AND hr.employees.last_name = employee_search_surname) 
		  AND sales.test_drive.start_time >= time_from
	ORDER BY sales.test_drive.start_time;
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION sales.observe_employee_test_drives IS 'Function to observe employee test drives';


-- 3. Function to observe employee contracts
CREATE or REPLACE FUNCTION finance.observe_employee_contracts(employee_search_name VARCHAR(20),
															  employee_search_surname VARCHAR(40),
															  time_from timestamp(0) with time zone DEFAULT NOW()
															 ) RETURNS TABLE (contract_id INT,
																			  employee_id SMALLINT,
																			  client_id INT,
																			  employee_first_name VARCHAR(20),
																			  employee_last_name VARCHAR(40),
																			  client_first_name VARCHAR(20),
																			  client_last_name VARCHAR(40),
																			  car_id INT,
																			  profit INT,
																			  date timestamp(0) with time zone)
AS
$$
BEGIN
	RETURN QUERY
	SELECT finance.contracts.id AS contract_id,
		   hr.employees.id AS employee_id,
		   sales.clients.id AS client_id,
	   	   hr.employees.first_name AS employee_first_name,
	   	   hr.employees.last_name AS employee_last_name,
	   	   sales.clients.first_name AS client_first_name,
	   	   sales.clients.last_name AS client_last_name,
	   	   finance.contracts.car_id,
	   	   finance.contracts.profit,
	   	   finance.contracts.date
	FROM finance.contracts
	LEFT JOIN hr.employees ON finance.contracts.employee_id = hr.employees.id
	LEFT JOIN sales.clients ON finance.contracts.client_id = sales.clients.id
	WHERE finance.contracts.employee_id IN (SELECT id FROM hr.employees WHERE hr.employees.first_name = employee_search_name AND hr.employees.last_name = employee_search_surname) 
		  AND finance.contracts.date >= time_from
	ORDER BY finance.contracts.date;
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION finance.observe_employee_contracts IS 'Function to observe employee constracts';


-- 4. Function to observe employee operations
CREATE or REPLACE FUNCTION sales.observe_employee_operations(employee_search_name VARCHAR(20),
															 employee_search_surname VARCHAR(40),
															 time_from timestamp(0) with time zone DEFAULT NOW()
															) RETURNS TABLE (operations_id BIGINT,
																			 employee_id SMALLINT,
																			 employee_first_name VARCHAR(20),
																			 employee_last_name VARCHAR(40),
																			 operations_type VARCHAR(40),
																			 timelog timestamp(0) with time zone)
AS
$$
BEGIN
	RETURN QUERY
	SELECT operations.operations.id AS operations_id,
		   hr.employees.id AS employee_id,
		   hr.employees.first_name AS employee_first_name,
		   hr.employees.last_name AS employee_last_name,
		   operations.operations_type.name AS operations_type,
		   operations.operations.timelog
	FROM operations.operations
	LEFT JOIN hr.employees ON operations.operations.employee_id = hr.employees.id
	LEFT JOIN operations.operations_type ON operations.operations.type_id = operations.operations_type.id
	WHERE operations.operations.employee_id IN (SELECT id FROM hr.employees WHERE hr.employees.first_name = employee_search_name AND hr.employees.last_name = employee_search_surname) 
		  AND operations.operations.timelog >= time_from
	ORDER BY operations.operations.timelog;
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION sales.observe_employee_operations IS 'Function to observe employee operations';