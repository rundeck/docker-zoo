# Deploy Rundeck Enterprise on Kubernetes

This example deploys a 2-node Rundeck Enterprise cluster with Mysql DB and Minio as logstorage.

This is a workable architecture that can easily be used as a basis for deploying a fully HA production Rundeck cluster.

## Secrets and connectors

Since this installation involves several services, they all need to be connected. So first we will create the encryption keys and user authentication information needed to tie this all together.

### Create Storage converter secret

Create a master password for the storage converter - this encrypts Rundeck secrets as they get written to disk. You can refer to the documentation here:

https://docs.rundeck.com/docs/administration/configuration/storage-facility.html#storage-converters

```
echo -n 'masterpassword123.' > ./masterpassword
kubectl create secret generic rundeckpro-storage-converter --from-file=./masterpassword

```

### Create Log Storage Access Credentials

Create the AWS access key/secret to access the log storage (S3 or any similar storage based on S3, like minio)

Note: you should probably create your own secrets values here.

```
echo -n 'minio' > ./awskey
echo -n 'minio123' > ./awssecret
kubectl create secret generic rundeckpro-log-storage --from-file=./awskey --from-file=./awssecret
```

### Create Mysql database password

```
echo -n 'rundeck123.' > ./password
kubectl create secret generic mysql-rundeckuser --from-file=./password
```


### Create License Key Secret

Add the Rundeck Enterprise license key as a Kubernetes secret. You will need a license key from your Rundeck account team for this step. Copy that license key into the data subdirectory of this path as ./data/rundeckpro-license.key

```
kubectl create secret generic rundeckpro-license --from-file=./data/rundeckpro-license.key
```

### Add custom ACL from secrets

By default, Rundeck manages ACL groups via a config file placed on the Rundeck instance. We'll store that config file as a Kubernetes secret, enabling us to keep it encrypted at rest as well as edit the ACLs later. To pick up the changes, delete the pods and let Kubernetes reschedule them.

```
kubectl create secret generic rundeckpro-admin-acl --from-file=./data/admin-role.aclpolicy
```

## Deploy database and storage

Rundeck Enterprise in a cluster configuration works better with common database and log storage. This step will stand up our underlying services for the Rundeck cluster.


```
kubectl apply -f persistent-volumes.yaml
kubectl apply -f minio-deployment.yaml
kubectl apply -f mysql-deployment.yaml
```

## Deploy Rundeck

### Ingress Controller

For this example, we are using Nginx as an ingress controller, which allows us to use the sticky sessions. Sticky sessions is required for clustered Rundeck.

We are using this ingress controller: https://kubernetes.github.io/ingress-nginx/
You will need to install it in order to make this example works (see https://kubernetes.github.io/ingress-nginx/deploy/):


* First, install the common Nginx components. This is mandatory for any Nginx ingress on Kubernetes.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

```

* Next, run the provider specific steps for Nginx ingress (see https://kubernetes.github.io/ingress-nginx/deploy/)

On a local Docker Desktop environment:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

```

If you are running this in a different environment, please refer to the documentation linked above.

### Create Rundeckpro deployment

The required Rundeck configuration options are already set in this file. Please read and review it to make sure it fits your intended purpose, or add to it if necessary.

```
kubectl apply -f rundeckpro-deployment.yaml

```


## Uninstall

```

kubectl delete deployment,service rundeckpro
kubectl delete ingress rudeckpro-nginx
kubectl delete deployment,service mysql
kubectl delete deployment,service minio
kubectl delete job minio-create-bucket
```

Note: These delete commands leave the persistent volumes and secrets in place so you can start up the environment again rather easily.
