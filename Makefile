launch_db:
	chmod +x init_docker_named_volumes.sh
	./init_docker_named_volumes.sh
	docker-compose up -d
rebuild_restart_db:
	docker stop postgresql-autodiller-db-test
	docker rm -f postgresql-autodiller-db-test
	docker rmi -f postgresql-autodiller-db-test
	docker-compose up -d
init_insert_db:
	docker exec -it postgresql-autodiller-db-test bash
	psql -U postgres -d autodiller_salon -f /root/sql_dmls/init_insert.sql
simulate_operations_db:
	docker exec -it postgresql-autodiller-db-test bash
	psql -U postgres -d autodiller_salon -f /root/sql_dmls/simulate_operations.sql
