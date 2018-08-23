# Deploy Rundeck PRO 

This example deploy a Rundeck PRO cluster with Mysql DB and Minio as logstorage

## Create Storage converter secret

Create a master password for the storage converter

```
echo -n 'masterpassword123.' > ./masterpassword
kubectl create secret generic rundeckpro-storage-converter --from-file=./masterpassword

```

## Create Storage Access Key

Create the AWS access key/secret to access the log storage (S3 or any similar storage based on S3, like minio)
```
echo -n 'minio' > ./awskey
echo -n 'minio123' > ./awssecret
kubectl create secret generic rundeckpro-log-storage --from-file=./awskey --from-file=./awssecret
```

## Create Mysql database password

Create database password as secret

```
echo -n 'rundeck123.' > ./password
kubectl create secret generic mysql-rundeckuser --from-file=./password
```


## Create License Key Secret

Add the Rundeck PRO license key as secret.

```
kubectl create secret generic rundeckpro-license --from-file=./data/rundeckpro-license.key
```

## Add custom ACL from secrets

Custom acls

```
kubectl create secret generic rundeckpro-admin-acl --from-file=./data/admin-role.aclpolicy
```

## Deploy database and storage (Optional)

A common database and log-storage is needed on a rundeckpro Cluster.
This is "optional" in case you want to use a db/storage located on k8s.

```
kubectl apply -f persistent-volumes.yaml
kubectl apply -f minio-deployment.yaml
kubectl apply -f mysql-deployment.yaml
```

## Deploy Rundeck 

```
kubectl apply -f rundeckpro-deployment.yaml

```
