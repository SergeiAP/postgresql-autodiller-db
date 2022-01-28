launch_dockerfile_db:
	docker build -t autodiller-db_postgres .
	docker run --name autodiller-db_postgres -p 5433:5432 autodiller-db_postgres
rebuild_restart_dockerfile_db:
	docker rm -f autodiller-db_postgres
	make launch_dockerfile_db
launch_docker_compose_db:
	chmod +x init_docker_named_volumes.sh
	./init_docker_named_volumes.sh
	docker-compose up -d
rebuild_restart_docker_compose_db:
	docker stop autodiller-db_postgres
	docker rm -f autodiller-db_postgres
	docker rmi -f autodiller-db_postgres
	docker-compose up -d
init_insert_db:
	docker exec -it autodiller-db_postgres bash
	psql -U postgres -d autodiller_salon -f /root/sql_dmls/init_insert.sql
simulate_operations_db:
	docker exec -it autodiller-db_postgres bash
	psql -U postgres -d autodiller_salon -f /root/sql_dmls/simulate_operations.sql
