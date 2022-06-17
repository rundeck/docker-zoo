Percona XtraDB Exhibit
=======================

Demonstrates Rundeck + Simple Percona cluster setup

### Setup

#### Create database certificates
Generate the certificates used by the percona cluster nodes:
```shell
$ make certs
```
A `certs`directory with the generated certs will be created.

#### First-time Bootstrap of the DB cluster
The first time you need to run the `rddbnode1` container first to bootstrap the cluster:
```
docker compose up rddbnode1 -d
```

- Log into the created mysql node and temporarily disable cluster checks.
```mysql
mysql> SET GLOBAL pxc_strict_mode=PERMISSIVE;
```

Run the rundeck war in dbmigration mode so it creates the database schema:
```shell
java -jar rundeck.war -m
```

Enable strict mode again on the database cluster.
```mysql
mysql> SET GLOBAL pxc_strict_mode=ENFORCING;
```

Then start the other database nodes:
```
docker compose up rddbnode2 rddbnode3 -d
```

### Startup
```
docker-compose up -d
```

### Teardown
```
docker-compose down -v
```
