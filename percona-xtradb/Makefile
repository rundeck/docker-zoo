RUNDECK_VERSION ?= 4.1.0
RUNDECK_IMAGE ?= rundeckpro/enterprise
PERCONA_IMAGE ?= percona/percona-xtradb-cluster:8.0

default: bootstrap

certs:
	mkdir -m 777 -p $(PWD)/certs
	docker run --name pxc-cert --rm -v $(PWD)/certs:/cert $(PERCONA_IMAGE) mysql_ssl_rsa_setup -d /cert

bootstrap: certs
	docker compose up rddbnode1 -d
	echo "wait 30 seconds for main to start..." && sleep 30
	echo "you may now start..."

dbstart:
	docker compose up rddbnode1 rddbnode2 rddbnode3 -d

rdstart:
	docker compose up rundeck -d

destroy:
	docker-compose down -v
	rm -rf $(PWD)/certs

.PHONY: default
