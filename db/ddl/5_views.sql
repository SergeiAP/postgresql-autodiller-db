-- 1. VIEW for client service statistics (tables sales.clients, sales.clients_services, sales.services)
CREATE OR REPLACE VIEW sales.sales_client_service_statistics_view AS
	SELECT sales.clients.first_name,
		   sales.clients.last_name,
		   sales.services.name AS service_name,
		   sales.clients_services.count_num AS ordered_counts
	FROM sales.clients
	LEFT JOIN sales.clients_services ON sales.clients.id = sales.clients_services.clients_id
	LEFT JOIN sales.services ON sales.clients_services.services_id = sales.services.id;
COMMENT ON VIEW sales.sales_client_service_statistics_view IS 'VIEW for client service statistics (tables sales.clients, sales.clients_services, sales.services)';
	
-- 2. VIEW for finance.contracts with employee name and surname, car model and client
CREATE OR REPLACE VIEW finance.contracts_view AS
	SELECT finance.contracts.id,
		   hr.employees.first_name AS employee_name,
		   hr.employees.last_name AS employee_surname,
		   sales.clients.first_name AS client_name,
		   sales.clients.last_name AS client_surname,
		   finance.contracts.car_id,
		   finance.contracts.profit,
		   finance.contracts.date
	FROM finance.contracts
	LEFT JOIN hr.employees ON finance.contracts.employee_id = hr.employees.id
	LEFT JOIN sales.clients ON finance.contracts.client_id = sales.clients.id;
COMMENT ON VIEW finance.contracts_view IS 'VIEW for finance.contracts with employee name and surname, car model and client';

-- 3. VIEW for operations.operations whith operation names and employee names
CREATE OR REPLACE VIEW operations.operations_view AS
	SELECT operations.operations.id,
		   hr.employees.first_name,
		   hr.employees.last_name,
		   operations.operations_type.name,
		   operations.operations.timelog
	FROM operations.operations
	LEFT JOIN hr.employees ON operations.operations.employee_id = hr.employees.id
	LEFT JOIN operations.operations_type ON operations.operations.type_id = operations.operations_type.id;
COMMENT ON VIEW operations.operations_view IS 'VIEW for operations.operations whith operation names and employee names';

-- 4. VIEW for observe car statuses using reviewed_cars and related names
CREATE OR REPLACE VIEW sales.reviewed_cars_view AS
	WITH chosen_clients AS 
		(SELECT sales.car_market.id AS car_id_, sales.clients.id AS client_id, first_name AS client_fn, last_name AS client_ln
		 FROM sales.clients
		 LEFT JOIN sales.car_market ON sales.clients.id = sales.car_market.client_id
		 WHERE sales.car_market.id IN (SELECT car_id FROM sales.reviewed_cars))
	SELECT sales.reviewed_cars.car_id,
		   chosen_clients.client_id,
		   chosen_clients.client_fn,
		   chosen_clients.client_ln,
		   hr.employees.first_name AS employee_fn,
		   hr.employees.last_name AS employee_ln,
		   sales.reviewed_cars.estimated_cost_cent,
		   sales.reviewed_cars.estimated_price_cent,
		   sales.reviewed_cars.estimated_profit_cent,
		   operations.operations_type.name
	FROM sales.reviewed_cars
	LEFT JOIN chosen_clients ON sales.reviewed_cars.car_id = chosen_clients.car_id_
	LEFT JOIN hr.employees ON sales.reviewed_cars.employee_id = hr.employees.id
	LEFT JOIN operations.operations_type ON sales.reviewed_cars.status_id = operations.operations_type.id;
COMMENT ON VIEW sales.reviewed_cars_view  IS 'VIEW for observe car statuses using reviewed_cars and related names';

-- 5. VIEW for cars in test drive
CREATE OR REPLACE VIEW sales.view_future_test_drives_view  AS
	SELECT sales.test_drive.car_id,
		   hr.employees.first_name AS employee_name,
		   hr.employees.last_name AS employee_surname,
		   sales.clients.first_name AS client_name,
		   sales.clients.last_name AS client_surname,
		   sales.test_drive.start_time,
		   sales.test_drive.end_time
	FROM sales.test_drive
	LEFT JOIN hr.employees ON sales.test_drive.employee_id = hr.employees.id
	LEFT JOIN sales.clients ON sales.test_drive.client_id = sales.clients.id
	WHERE sales.test_drive.start_time >= NOW();
COMMENT ON VIEW sales.view_future_test_drives_view IS 'VIEW for cars in test drive';