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
