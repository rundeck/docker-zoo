RUNDECK_VERSION ?= 4.1.0
RUNDECK_IMAGE ?= rundeckpro/enterprise
PERCONA_IMAGE ?= percona/percona-xtradb-cluster:8.0

default: bootstrap

certs:
	mkdir -m 777 -p $(PWD)/certs
	docker run --name pxc-cert --rm -v $(PWD)/certs:/cert $(PERCONA_IMAGE) mysql_ssl_rsa_setup -d /cert

bootstrap: certs
	docker compose up rddbnode1 -d
	echo "wait 35 seconds for main db to start..." && sleep 35
	echo "Disabling cluster strict mode..."
	docker compose exec rddbnode1 mysql -hlocalhost -uroot -proot rundeck -e "SET GLOBAL pxc_strict_mode=PERMISSIVE;"
	docker compose run -i --rm rdbootstrap
	echo "wait 5 seconds before enforcing strict mode again" && sleep 5
	docker compose exec rddbnode1 mysql -hlocalhost -uroot -proot rundeck -e "SET GLOBAL pxc_strict_mode=ENFORCING;"
	docker compose up rddbnode2 -d
	docker compose up rddbnode3 -d

dbstart:
	docker compose up rddbnode1 rddbnode2 rddbnode3 -d

start:
	docker compose up rundeck -d

destroy:
	docker compose down -v
	rm -rf $(PWD)/certs

.PHONY: default
