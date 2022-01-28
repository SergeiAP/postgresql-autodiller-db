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
