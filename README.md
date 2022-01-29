---
title: "Postgresql autodiller db"
author: "Sergei Parshin"
date: "January, 29, 2022"
output: "html_document"
---
## 1. Description
The repository includes a dsigned __PostgreSQL__ database for the Auto diller. It is education project from the [Database design course](https://stepik.org/course/51675) which was started from scratch based on Business requirements.

__The project includes__:
1. Descriptions and diagrams of the design phase in [Miro](https://miro.com/app/board/o9J_ll5qrzQ=/?invite_link_id=587830638461)
2. ERD (Entity Relationship Diagram) created in pgAdmin
3. DDL (Data Definition Language) commands to initialize database itself and related functions, procedures and trigers
4. DML (Data Manipulation Language) commands to fill the database and simulate database operations
5. Common comands to container operations (based on Makefile) and use database itself (based on functions, views)

__Stack__: PostgreSQL (DDL, DML, ERD), pgAdmin, docker, docker-compose, bash, makefile, git

__Prerequirements__: [docker](https://docs.docker.com/engine/install/ubuntu/)

__Optional__: [docker-compose](https://docs.docker.com/compose/install/), [pgAdmin](https://www.pgadmin.org/download/)
## 2. Repo structure
__Folders__:
  - __`db`__ - files to initialize database.Iincludes `Dockerfile` for `docker-compose.yml` and `ddl` (Data Definition Language) files.
  - __`dml`__ - Data Manipulation Language files/commands. Includes `init_insert.sql` to fill database with initial values and `simulate_operations.sql` to simulate manipulation with the database.
  - __`info`__ - stores any additional database-related files. E.g. ERD (Entity Relationship Diagram) for the database.

__Files__:
  - `Makefile` - the file containing shell commands with set of tasks to be executed. The file could be execute as a whole or partly. [Read more](https://makefiletutorial.com/).
  - `docker-compose.yml` - one (out of 2) way to build the project. Apply to `Dockerfile` in __`db`__. To use docker-compose it is required to install [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/).
  - `Dockerfile-init` - second (out of 2) way to build the project. It is required to install docker.
  - `init_docker_named_volumes.sh` - bash script to create named volumes which going to be used in `docker-compose.yml`.
## 3. Project launching
There are __two ways to launch the project__:
* dockerfile:
  1. Install [docker](https://docs.docker.com/engine/install/)
  2. Clone/download the repository
  3. Open the project with `Makefile`, run *`make launch_dockerfile_db`* to build the database and run __`dml`__ scripts
  4. Connect to `http:\\localhost:5433` or `http:\\YOUR_SERVER_IP:5433` using pgAdmin, bash or other methods
* docker-compose:
  1. Install [docker](https://docs.docker.com/engine/install/)
  2. Install [docker-compose](https://docs.docker.com/compose/install/)
  3. Clone/download the repository
  4. Open the project with `Makefile`, run _`make launch_docker_compose_db`_ to build the database and run __`dml`__ scripts and mount `docker volumes`
  5. Connect to `http:\\localhost:5433` or `http:\\YOUR_SERVER_IP:5433` using pgAdmin, bash or other methods

__Insert commands__ (optional, but desired):
  1. Fill database by default data _`make init_insert_db`_
  2. Fill operational tables/simulate database operations _`make simulate_operations_db`_
## 4. Other commands
To rebuild containers use _`make rebuild_dockerfile_db`_ or _`make rebuild_docker_compose_db`_ debenting on the way of project launching in p.3.
## 5. Common queries

1. Views
```sql
-- VIEW for client service statistics (tables sales.clients, sales.clients_services, sales.services)
SELECT * FROM sales.sales_client_service_statistics_view;
```
```sql
-- VIEW for finance.contracts with employee name and surname, car model and client
SELECT * FROM finance.contracts_view;
```
```sql
-- VIEW for operations.operations whith operation names and employee names
SELECT * FROM operations.operations_view ORDER BY timelog DESC;
```
```sql
-- VIEW for observe car statuses using reviewed_cars and related names
SELECT * FROM sales.reviewed_cars_view ORDER BY car_id DESC;
```
```sql
-- VIEW for cars in test drive
SELECT * FROM sales.view_future_test_drives_view ORDER BY car_id DESC;
```

2. Functions
```sql
-- FUNCTION to observe car test drives
SELECT * FROM sales.observe_car_test_drives(
  car_search := 3,
  time_from := '2021-11-24 15:00:00+00')
```
```sql
-- FUNCTION to observe employee test drives
SELECT * FROM sales.observe_employee_test_drives(
  employee_search_name := 'Antoine',
  employee_search_surname := 'Davis',
  time_from := '2021-11-24 15:00:00+00')
```
```sql
-- FUNCTION to observe employee contracts
SELECT * FROM finance.observe_employee_contracts(
  employee_search_name := 'Adler',
  employee_search_surname := 'Smith',
  time_from := '2021-11-24 15:00:00+00')
```
```sql
-- FUNCTION to observe employee operations
SELECT * FROM sales.observe_employee_operations(
  employee_search_name := 'Adler',
  employee_search_surname := 'Smith',
  time_from := '2021-11-24 15:00:00+00')
ORDER BY timelog;
```
## X. TODO
1. Add `restart` option in `Makefile` with saved database data/volumes.
2. Fix timestamps for contracts (see `finance.contracts_view`) and for operations (see `operations.operations_view`). Now timestaps are filled by `NOW()`.
3. Add descrition for pgAdmin installation.
## Contacts
In terms of any questions please 📧 to the owner __Sergei Parshin__:
* [mail](mailto:Sergei.A.P@yandex.com)
* Telegram: @ParshinSA
* [LinkedIn](https://www.linkedin.com/in/sergei-parshin/)
