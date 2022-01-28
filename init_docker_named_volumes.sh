#Create a volume to store data from database
docker volume create autodiller-db-data 
sudo chmod +007 $(docker volume inspect --format '{{ .Mountpoint }}' autodiller-db-data)

#Create a volume to store some useful sql's e.g. for data inserting to use them in the container on-demand
docker volume create  autodiller-db-sqls
sudo chmod +007 $(docker volume inspect --format '{{ .Mountpoint }}' autodiller-db-sqls)
cp ./dml/* $(docker volume inspect --format '{{ .Mountpoint }}' autodiller-db-sqls)
