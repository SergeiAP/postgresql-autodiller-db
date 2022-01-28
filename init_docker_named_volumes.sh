#Create a volume to store data from database
docker volume create postgresql-autodiller-test-db-data 
sudo chmod +007 $(docker volume inspect --format '{{ .Mountpoint }}' postgresql-autodiller-test-db-data)

#Create a volume to store some useful sql's e.g. for data inserting to use them in the container on-demand
docker volume create  postgresql-autodiller-test-db-sqls
sudo chmod +007 $(docker volume inspect --format '{{ .Mountpoint }}' postgresql-autodiller-test-db-sqls)
cp ./dml/* $(docker volume inspect --format '{{ .Mountpoint }}' postgresql-autodiller-test-db-sqls)
