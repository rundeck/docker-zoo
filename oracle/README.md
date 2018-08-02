Oracle Exhibit
==============

## Setup

**Obtain Oracle JDBC Driver**  
> **NOTE:** Oracle requires executing their license/agreement before obtaining their JDBC driver!

Download the Oracle JDBC driver and place in `lib/` .

**Setup database**  
Bring up the Oracle container first:
```
docker-compose up -d oracle
```

Connect and setup user:
```
docker exec -it <container> bash -c "source /home/oracle/.bashrc; sqlplus sys/Oradoc_db1@ORCLPDB1 as sysdba"

create USER rundeck IDENTIFIED BY rundeck;
GRANT CONNECT, RESOURCE, DBA TO rundeck;
```

**Start Rundeck**
```
docker-compose up -d rundeck
```