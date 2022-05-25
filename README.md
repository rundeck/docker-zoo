Rundeck Docker Zoo
==================

Welcome to Rundeck's docker Zoo! Here we have many exhibits, both
common _and_ exotic.

These examples are great for trying out Rundeck in different setups,
as well as a reference and starting place for your own deployments.

## Topics

### Authentication
* [ldap](./ldap)
* [ldap-combined](./ldap-combined)

### Extending Configuration 
* [config](./config)

### External Database Config
* [mysql](./mysql)
* [oraclexe](./oraclexe)
* [postgres](./postgres)
* [sqlserver](./sqlserver)

### Kubernetes
* `Pro` [kubernetes](./kubernetes)

### Plugin Bundling
* [cloud](./cloud)
* [config](./config)

### Reverse Proxy
* [cloud](./cloud)


## Conventions

### Config via `.env`
Each docker-compose based exhibit has a `.env.dist` file that can be used to
configure the example after being copied to `.env` . Some require it be populated
and will call this out in the instructions. For all others it can be used to
changed the Rundeck docker image and other various defaults.


### Rundeck Enterpise (fka Pro) images
For each exhibit copy `.env.dist` to `.env` and uncomment the
**pro** section. Provide the desired image and license file location:
```bash
RUNDECK_IMAGE=rundeckpro/enterprise:SNAPSHOT
RUNDECK_LICENSE_FILE=/path/to/rundeck-license.key
```

### Updating/Changing Images
For docker-compose without builds:
```
docker-compose down
docker-compose pull
```

For docker-compose with builds:
```
docker-compose down
docker-compose pull && docker-compose build --pull
docker-compose up
```

### Teardown
To remove the setup including data volumes:
```
docker-compose down --volumes
```
