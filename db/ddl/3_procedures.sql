-- 1. Procedure to update operations table (using in triggers)
CREATE or REPLACE FUNCTION operations.insert_operation(employee_id smallint,
													   status VARCHAR(40),
													   timelog_var timestamp(0) with time zone DEFAULT NOW()
													  ) RETURNS VOID
AS
$$
DECLARE
	operation_id INT;
BEGIN
	operation_id := (SELECT id FROM operations.operations_type WHERE name = status);
	INSERT INTO  operations.operations (employee_id, type_id, timelog) VALUES 
		(employee_id, operation_id, timelog_var);
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION operations.insert_operation IS 'Procedure to update operations table based on status name (using in triggers)';

CREATE or REPLACE FUNCTION operations.insert_operation_id(employee_id smallint,
														  status_id smallint,
														  timelog_var timestamp(0) with time zone DEFAULT NOW()
														 ) RETURNS VOID
AS
$$
DECLARE
	operation_id INT;
BEGIN
	INSERT INTO  operations.operations (employee_id, type_id, timelog) VALUES 
		(employee_id, status_id, timelog_var);
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION operations.insert_operation IS 'Procedure to update operations table based on id_type (using in triggers)';


-- 2. Procedure to add info about used services by client

CREATE or REPLACE FUNCTION sales.add_client_ordered_services(client_name VARCHAR(20),
															 client_surname VARCHAR(40),
															 client_phone phone_number,
															 service_name VARCHAR(40),
															 service_count SMALLINT DEFAULT 1
															) RETURNS void
AS
$$
DECLARE
	client_id INT;
	service_id INT;
BEGIN
	-- Choose service and client id's
	client_id := (SELECT id FROM sales.clients 
					WHERE first_name = client_name
					AND last_name = client_surname
					AND phone = client_phone);
	service_id := (SELECT id FROM sales.services 
					WHERE name = service_name);
	-- Create temp table with 
	CREATE TEMPORARY TABLE tmp_clients_services AS (
		SELECT clients_id, services_id, count_num FROM sales.clients_services
			WHERE clients_id = client_id
			AND services_id = service_id);
	IF NOT EXISTS (SELECT * FROM tmp_clients_services LIMIT 1) THEN
		INSERT INTO sales.clients_services (clients_id, services_id, count_num) VALUES 
			(client_id, service_id , service_count);
	ELSE
		UPDATE sales.clients_services
			SET count_num = count_num + service_count
			WHERE clients_id = client_id
			AND services_id = service_id;
	END IF;
	DROP TABLE tmp_clients_services;
END
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION sales.add_client_ordered_services IS 'Procedure to add info about used services by the client';