Simple Cluster Exhibit
=============

Demonstrates configuring a Rundeck Enterprise Cluster, with NGinx as Load Balancer.

### Setup

- Copy the provided `.env.dist` file as `.env`, and edit the values as needed providing the correct license file.
- If you want to increase the cluster size, you'll need to adjust the `replicas` parameters in the `docker-compose.yml` file.
And also adjust the `upstream` servers in the `nginx.conf` file. This in order to use nginx as actual load balancer
instead of docker's default round-robin load balancer.


### Startup
```
docker-compose up
```

### Teardown
```
docker-compose down -v
```