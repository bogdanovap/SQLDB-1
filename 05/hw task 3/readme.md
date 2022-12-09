SQL-files to create tables are located in directores, corresponding to DB.

To start containers run:
```
docker-compose up
```
To connect to mysql in container run following comamnd:
```
sudo docker exec -it db_users mysql -uroot -p
{enter password. default: pass}
```