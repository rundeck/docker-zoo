#wait for the SQL Server to come up
sleep 10s

#run the setup script to create the DB and the schema in the DB
/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d master -i setup.sql
