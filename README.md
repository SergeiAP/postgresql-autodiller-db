### Launching of salomn database (PostgreSQL)

1. Посмотрите содержимое Dockerfile и папки ddl
2. Соберите докер-образ БД: `docker build -t my_db .`
3. Запустите докер-контейнер БД: `docker run --name my_db -p 5433:5432 my_db`
4. Откройте соединение в БД любым удобным вам инструментом. Локальный порт 5433, логин postgres, пароль postgres

#### Структура репозитория

#### Common queries

-- 1. Views
-- VIEW for client service statistics (tables sales.clients, sales.clients_services, sales.services)
SELECT * FROM sales.sales_client_service_statistics_view;

-- VIEW for finance.contracts with employee name and surname, car model and client
SELECT * FROM finance.contracts_view;

-- VIEW for operations.operations whith operation names and employee names
SELECT * FROM operations.operations_view ORDER BY timelog DESC;

-- VIEW for observe car statuses using reviewed_cars and related names
SELECT * FROM sales.reviewed_cars_view ORDER BY car_id DESC;

-- VIEW for cars in test drive
SELECT * FROM sales.view_future_test_drives_view ORDER BY car_id DESC;


-- 2.Functions
-- FUNCTION to observe car test drives
SELECT * FROM sales.observe_car_test_drives(car_search := 3, time_from := '2021-11-24 15:00:00+00')

-- FUNCTION to observe employee test drives
SELECT * FROM sales.observe_employee_test_drives(employee_search_name := 'Antoine', employee_search_surname := 'Davis', time_from := '2021-11-24 15:00:00+00')

-- FUNCTION to observe employee contracts
SELECT * FROM finance.observe_employee_contracts(employee_search_name := 'Adler', employee_search_surname := 'Smith', time_from := '2021-11-24 15:00:00+00')

-- FUNCTION to observe employee operations
SELECT * FROM sales.observe_employee_operations(employee_search_name := 'Adler', employee_search_surname := 'Smith', time_from := '2021-11-24 15:00:00+00') ORDER BY timelog;

#### TODO
1. Установить время timelog чтобы не иметь дефолтных значений.
