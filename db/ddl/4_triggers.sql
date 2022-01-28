-- 1. sales.reviewed_cars

-- Triggers for inserting new car or updating it 
CREATE or REPLACE FUNCTION sales.set_reviewed_cars_status()
RETURNS TRIGGER
AS
$$
BEGIN
	IF (NEW.estimated_price_cent IS NOT NULL) OR (NEW.estimated_cost_cent IS NOT NULL) THEN
		UPDATE sales.reviewed_cars SET status_id = (SELECT id FROM operations.operations_type WHERE name = 'estimated') WHERE car_id = NEW.car_id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_reviewed_cars AFTER UPDATE OF estimated_price_cent, estimated_cost_cent ON sales.reviewed_cars
FOR EACH ROW
EXECUTE PROCEDURE sales.set_reviewed_cars_status();

-- Triggers for inset or update status in sales.reviewed_cars
CREATE or REPLACE FUNCTION sales.insert_operations_from_reviewd_cars()
RETURNS TRIGGER
AS
$$
BEGIN
	PERFORM operations.insert_operation_id(NEW.employee_id::smallint, NEW.status_id::smallint, NOW());
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_update_reviewed_cars_status AFTER INSERT OR UPDATE OF status_id ON sales.reviewed_cars
FOR EACH ROW
EXECUTE PROCEDURE sales.insert_operations_from_reviewd_cars();

-- Triger for sales.reviewed_cars to calculate profit when cost and price filled
-- Update trigger
CREATE or REPLACE FUNCTION sales.update_set_reviewed_cars_profit()
RETURNS TRIGGER
AS
$$
BEGIN
	IF  (NEW.estimated_price_cent IS NOT NULL) AND (NEW.estimated_cost_cent IS NOT NULL) THEN
		UPDATE sales.reviewed_cars SET estimated_profit_cent = NEW.estimated_price_cent - NEW.estimated_cost_cent WHERE car_id = NEW.car_id;
	ELSIF (NEW.estimated_price_cent IS NOT NULL) AND (OLD.estimated_cost_cent IS NOT NULL) THEN
		UPDATE sales.reviewed_cars SET estimated_profit_cent = NEW.estimated_price_cent - OLD.estimated_cost_cent WHERE car_id = NEW.car_id;
	ELSIF (NEW.estimated_cost_cent IS NOT NULL) AND (OLD.estimated_price_cent IS NOT NULL) THEN
	UPDATE sales.reviewed_cars SET estimated_profit_cent = OLD.estimated_price_cent - NEW.estimated_cost_cent WHERE car_id = NEW.car_id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_reviewed_cars_profit AFTER UPDATE OF estimated_cost_cent, estimated_price_cent ON sales.reviewed_cars
FOR EACH ROW
EXECUTE PROCEDURE sales.update_set_reviewed_cars_profit();

-- Insert trigger if the employee wants to insert both estimated_price of car after service and estimated_cost of car buy + sale
CREATE or REPLACE FUNCTION sales.insert_set_reviewed_cars_profit()
RETURNS TRIGGER
AS
$$
BEGIN
	IF ((NEW.estimated_price_cent IS NOT NULL) AND (NEW.estimated_cost_cent IS NOT NULL)) THEN
		UPDATE sales.reviewed_cars SET estimated_profit_cent = NEW.estimated_price_cent - NEW.estimated_cost_cent WHERE car_id = NEW.car_id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_reviewed_cars_profit AFTER INSERT ON sales.reviewed_cars
FOR EACH ROW
EXECUTE PROCEDURE sales.insert_set_reviewed_cars_profit();


-- 2. sales.carpool

-- Trigger which insert operation when carpool status is set 
CREATE or REPLACE FUNCTION sales.insert_operations_from_carpool()
RETURNS TRIGGER
AS
$$
BEGIN
	EXECUTE operations.insert_operation(NEW.employee_id::smallint, NEW.status::VARCHAR(40), NOW());
	ALTER TABLE sales.reviewed_cars DISABLE TRIGGER insert_update_reviewed_cars_status;
	UPDATE sales.reviewed_cars SET status_id = (SELECT id FROM operations.operations_type WHERE name = 'bought') WHERE car_id = NEW.car_id;
	ALTER TABLE sales.reviewed_cars ENABLE TRIGGER insert_update_reviewed_cars_status;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_update_carpool_status AFTER INSERT ON sales.carpool
FOR EACH ROW
EXECUTE PROCEDURE sales.insert_operations_from_carpool();

-- Trigger which update operation when carpool status is set 
CREATE or REPLACE FUNCTION sales.update_operations_from_carpool()
RETURNS TRIGGER
AS
$$
BEGIN
	EXECUTE operations.insert_operation(NEW.employee_id::smallint, NEW.status::VARCHAR(40), NOW());
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_carpool_status AFTER UPDATE OF status ON sales.carpool
FOR EACH ROW
EXECUTE PROCEDURE sales.update_operations_from_carpool();

-- 3. sales.test_drive

-- Triger for sales.test_drive to calculate duration in minutes

CREATE or REPLACE FUNCTION sales.insert_set_test_drive_duration()
RETURNS TRIGGER
AS
$$
DECLARE
	duration_in_mins INT;
BEGIN
	IF (NEW.end_time IS NOT NULL) THEN
		duration_in_mins := (SELECT ROUND(EXTRACT(EPOCH FROM NEW.end_time - NEW.start_time)/60) FROM sales.test_drive WHERE id = NEW.id);
		UPDATE sales.test_drive SET duration_mins = duration_in_mins WHERE id = NEW.id;
		EXECUTE operations.insert_operation(NEW.employee_id::smallint, 'test drive'::varchar(40), NEW.end_time);
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

-- Update trigger
CREATE TRIGGER insert_test_drive_time AFTER INSERT ON sales.test_drive
FOR EACH ROW
EXECUTE PROCEDURE sales.insert_set_test_drive_duration();

-- Insert trigger if the employee wants to insert both start and end time
CREATE or REPLACE FUNCTION sales.update_set_test_drive_duration()
RETURNS TRIGGER
AS
$$
DECLARE
	duration_in_mins INT;
	employee_id_var INT;
	end_time_var TIMESTAMP WITH TIME ZONE;
BEGIN
	SELECT ROUND(EXTRACT(EPOCH FROM end_time - start_time)/60), employee_id, end_time 
		INTO duration_in_mins, employee_id_var, end_time_var
		FROM sales.test_drive
		WHERE id = NEW.id;
	UPDATE sales.test_drive SET duration_mins = duration_in_mins WHERE id = NEW.id;
	EXECUTE operations.insert_operation(employee_id_var::smallint, 'test drive'::varchar(40), end_time_var);
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_test_drive_time AFTER UPDATE OF start_time, end_time ON sales.test_drive
FOR EACH ROW
EXECUTE PROCEDURE sales.update_set_test_drive_duration();

-- [DEPRICATED]

/*
-- 2. finance.contracts
-- Triger for finance.contracts to calculate revenue when profit and loss filled
-- Update trigger
CREATE or REPLACE FUNCTION finance.update_set_contracts_revenue()
RETURNS TRIGGER
AS
$$
BEGIN
	IF ((NEW.profit IS NOT NULL) AND (NEW.loss IS NOT NULL)) 
	AND ((NEW.profit != OLD.profit) OR (NEW.loss != OLD.loss)) THEN
		UPDATE finance.contracts SET revenue = NEW.profit - NEW.loss WHERE id = NEW.id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_contracts_loss_profit AFTER UPDATE OF profit, loss ON finance.contracts
FOR EACH ROW
EXECUTE PROCEDURE finance.update_set_contracts_revenue();

-- Insert trigger if the employee wants to insert both profit and loss
CREATE or REPLACE FUNCTION finance.insert_set_contracts_revenue()
RETURNS TRIGGER
AS
$$
BEGIN
	IF ((NEW.profit IS NOT NULL) AND (NEW.loss IS NOT NULL)) THEN
		UPDATE finance.contracts SET revenue = NEW.profit - NEW.loss WHERE id = NEW.id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_contracts_loss_profit AFTER INSERT ON finance.contracts
FOR EACH ROW
EXECUTE PROCEDURE finance.insert_set_contracts_revenue();
*/

/*
-- 1. operations.operations
-- Triger for operations.operations to calculate duration in minutes
CREATE or REPLACE FUNCTION operations.set_operations_duration()
RETURNS TRIGGER
AS
$$
BEGIN
	IF (NEW.end_time IS NOT NULL) THEN
		UPDATE operations.operations SET duration_mins = ROUND(EXTRACT(EPOCH FROM end_time - start_time)/60) WHERE id = NEW.id;
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

-- Update trigger
CREATE TRIGGER update_operations_time AFTER UPDATE OF start_time, end_time ON operations.operations
FOR EACH ROW
EXECUTE PROCEDURE operations.set_operations_duration();

-- Insert trigger if the employee wants to insert both start and end time
CREATE TRIGGER insert_operations_time AFTER INSERT ON operations.operations
FOR EACH ROW
EXECUTE PROCEDURE operations.set_operations_duration();
*/