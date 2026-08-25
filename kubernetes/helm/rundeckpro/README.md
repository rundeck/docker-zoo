# Runbook Automation Helm Chart for AWS EKS

## Introduction

This Helm chart deploys PagerDuty Runbook Automation (formerly Rundeck) on AWS EKS in a production-ready, highly available configuration. Helm is the package manager for Kubernetes, making it easier to define, install, and upgrade even the most complex Kubernetes applications.

Using a Helm chart instead of raw manifest files offers several advantages:

- **Reusability:** Helm charts can be parameterized, making them reusable across environments.
- **Versioning:** Charts can be versioned and rolled back easily.
- **Simplicity:** A single command can install or upgrade all resources, reducing manual steps.
- **Consistency:** Ensures all resources are deployed together, minimizing configuration drift.
- **Templating:** Values can be injected at deploy time, supporting different configurations for dev, staging, and prod.

This guide uses AWS EKS as the Kubernetes engine and integrates with AWS services like Route53 for DNS, S3 for log storage, and RDS for the database.

## Architecture Overview

This chart deploys Runbook Automation in a clustered configuration with:

- **High Availability:** Multiple replicas with session affinity
- **Load Balancing:** AWS Application Load Balancer (ALB) with SSL termination
- **Persistent Storage:** RDS for database and S3 for execution logs
- **DNS Management:** ExternalDNS for automatic Route53 updates
- **Security:** Kubernetes secrets for sensitive data

## File Overview

Here's a brief explanation of each file in this chart:

### Chart Files

- **Chart.yaml**  
  Contains metadata about the Helm chart, such as name, version, description, maintainers, and keywords.

- **values.yaml**  
  The default configuration values for the chart. Users can override these when installing or upgrading the chart. Contains example values with placeholders for environment-specific settings.

### Template Files

- **templates/_helpers.tpl**  
  Template helpers file containing reusable template snippets (like naming conventions) to keep the chart DRY and maintainable.

- **templates/deployment.yaml**  
  The Kubernetes Deployment template defining how Rundeck pods are created and managed. Includes environment variables, resource limits, volume mounts, and cluster configuration.

- **templates/service.yaml**  
  The Kubernetes Service template exposing Rundeck within the cluster with session affinity for maintaining user sessions.

- **templates/ingress.yaml**  
  The Kubernetes Ingress template managing external access via AWS ALB with SSL termination and health checks.

- **templates/secrets.yaml**  
  The Kubernetes Secret templates for ACL files, kubeconfig, and realm properties. These are populated using `--set-file` during installation.

- **templates/configMap.yaml**  
  ConfigMap templates for node sources and optional certificate configurations.

## Prerequisites

Before deploying this Helm chart, ensure you have:

### Required Tools

- **Helm 3.x** installed on your local machine or CI/CD environment
- **kubectl** configured to access your EKS cluster
- **AWS CLI** configured with appropriate permissions

### Required AWS Infrastructure

- **EKS Cluster** with appropriate node groups
- **AWS Load Balancer Controller** - [Installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html)
  - Enables management of AWS ALB directly from Kubernetes
- **ExternalDNS** - [Installation Guide](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws-load-balancer-controller.md)
  - Automatically updates Route53 DNS records
- **RDS Database** (MySQL/MariaDB compatible with Rundeck)
- **S3 Bucket** for execution log storage
- **Route53 Hosted Zone** for DNS management
- **ACM Certificate** for your domain

### IAM Permissions

Your EKS nodes need IAM permissions for:
- Reading/writing to S3 bucket
- Connecting to RDS database
- (Optional) Reading secrets from AWS Secrets Manager

## Required Secrets

This chart expects several secrets to be configured before installation:

### 1. ACL File Secret (Admin Permissions)

The ACL (Access Control List) file defines administrative permissions for Rundeck. Create the required secret using Helm's `--set-file` option during installation:

```bash
helm install rundeckpro . \
  --set-file aclFile=/path/to/admin-role.aclpolicy
```

**Example ACL file** (`admin-role.aclpolicy`):
```yaml
description: Admin project level access control
context:
  project: '.*' # all projects
for:
  resource:
    - equals:
        kind: job
      allow: [create, delete, read, update, run, kill]
    - equals:
        kind: node
      allow: [read, create, update, refresh]
    - equals:
        kind: event
      allow: [read, create]
  adhoc:
    - allow: [read, run, kill]
  node:
    - allow: [read, run]
by:
  group: admin
---
description: Admin Application level access control
context:
  application: 'rundeck'
for:
  resource:
    - equals:
        kind: project
      allow: [create, delete, read, update]
    - equals:
        kind: system
      allow: [read, enable_executions, disable_executions, admin]
    - equals:
        kind: system_acl
      allow: [read, create, update, delete, admin]
    - equals:
        kind: user
      allow: [admin]
  project:
    - match:
        name: '.*'
      allow: [read, import, export, configure, delete, admin]
  storage:
    - match:
        path: '(keys|keys/.*)'
      allow: [read, create, update, delete]
by:
  group: admin
```

### 2. Kubeconfig File Secret (Optional)

If you want Rundeck to manage Kubernetes resources, provide a kubeconfig file:

```bash
helm install rundeckpro . \
  --set-file kubeconfig=/path/to/kubeconfig
```

### 3. Realm Properties File Secret

The realm.properties file defines local user accounts for file-based authentication:

```bash
helm install rundeckpro . \
  --set-file realm=/path/to/realm.properties
```

**Example realm.properties file**:
```properties
# Format: username:password,user,role1,role2
admin:admin,user,admin,architect,deploy,build
user:user,user,dev,ops
```

### 4. Database Password Secret

The database password **is sensitive** and should **not** be written to any file or included in `values.yaml`. Create it directly in Kubernetes:

```bash
kubectl create secret generic database-password \
  --from-literal=password='YOUR_SECURE_PASSWORD' \
  --namespace=rundeck
```

**Important:** Make sure the secret name matches what's referenced in the deployment template (`database-password`).

## Required Values Configuration

Before deploying, you must customize these values in `values.yaml` or via `--set` flags:

### Namespace
```yaml
namespace: rundeck  # Your Kubernetes namespace
```

### Ingress Configuration
```yaml
ingress:
  host: rundeck.example.com  # Your domain
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/id
    external-dns.alpha.kubernetes.io/hostname: "rundeck.example.com"
```

### Rundeck Configuration
```yaml
rundeck:
  env:
    RUNDECK_GRAILS_URL: "https://rundeck.example.com"
    RUNDECK_DATABASE_URL: "jdbc:mysql://your-rds-endpoint.rds.amazonaws.com/rundeck?autoReconnect=true"
    RUNDECK_DATABASE_USERNAME: "rundeckuser"
    RUNDECK_PLUGIN_EXECUTIONFILESTORAGE_S3_BUCKET: "your-s3-bucket"
    RUNDECK_PLUGIN_EXECUTIONFILESTORAGE_S3_REGION: "us-west-2"
```

### LDAP/AD Configuration (Optional)

If using LDAP/AD authentication, configure these values:
```yaml
rundeck:
  env:
    RUNDECK_JAAS_LDAP_PROVIDERURL: "ldap://your-ldap-server.example.com:389"
    RUNDECK_JAAS_LDAP_BINDDN: "CN=rundeck,OU=Users,DC=example,DC=com"
    RUNDECK_JAAS_LDAP_BINDPASSWORD: "changeme"
    RUNDECK_JAAS_LDAP_USERBASEDN: "OU=Users,DC=example,DC=com"
```

**Note:** If not using LDAP, remove these settings from `values.yaml`.

## Installation

### 1. Create Namespace

```bash
kubectl create namespace rundeck
```

### 2. Create Database Password Secret

```bash
kubectl create secret generic database-password \
  --from-literal=password='YOUR_DATABASE_PASSWORD' \
  --namespace=rundeck
```

### 3. Prepare Configuration Files

Create or obtain these files:
- `admin-role.aclpolicy` - Admin ACL permissions
- `realm.properties` - Local user accounts
- `kubeconfig` - (Optional) Kubernetes access

### 4. Customize values.yaml

Edit `values.yaml` to set your specific configuration values (see Required Values Configuration above).

### 5. Install the Chart

```bash
helm install rundeckpro ./rundeckpro \
  --namespace=rundeck \
  --set-file aclFile=./admin-role.aclpolicy \
  --set-file realm=./realm.properties \
  --set-file kubeconfig=/path/to/kubeconfig \
  --values values.yaml
```

### 6. Verify Deployment

```bash
# Check pods
kubectl get pods -n rundeck

# Check service
kubectl get svc -n rundeck

# Check ingress
kubectl get ingress -n rundeck

# View logs
kubectl logs -n rundeck -l app.kubernetes.io/name=rundeckpro --tail=100
```

## Upgrading

To upgrade the release with new values or chart changes:

```bash
helm upgrade rundeckpro ./rundeckpro \
  --namespace=rundeck \
  --set-file aclFile=./admin-role.aclpolicy \
  --set-file realm=./realm.properties \
  --values values.yaml
```

## Uninstalling

To remove all resources created by this chart:

```bash
helm uninstall rundeckpro --namespace=rundeck
```

**Note:** This will delete all Kubernetes resources associated with the release, including deployments, services, ingress, and secrets. It will NOT delete:
- The RDS database
- S3 bucket and logs
- Route53 records (may persist depending on ExternalDNS configuration)

## Configuration Examples

### Production Environment

```yaml
replicaCount: 3

resources:
  requests:
    memory: "4Gi"
    cpu: "1000m"
  limits:
    memory: "6Gi"
    cpu: "2000m"

rundeck:
  env:
    JAVA_OPTS: "-Xms4g -Xmx5g"
```

### Development Environment

```yaml
replicaCount: 1

resources:
  requests:
    memory: "2Gi"
    cpu: "500m"
  limits:
    memory: "3Gi"
    cpu: "1000m"

rundeck:
  env:
    JAVA_OPTS: "-Xms2g -Xmx2.5g"
```

### Using Custom Values File

```bash
# Create custom-values.yaml with environment-specific overrides
helm install rundeckpro ./rundeckpro \
  --namespace=rundeck \
  --values values.yaml \
  --values custom-values.yaml \
  --set-file aclFile=./admin-role.aclpolicy
```

## Troubleshooting

### Pods Not Starting

Check pod status and logs:
```bash
kubectl get pods -n rundeck
kubectl describe pod <pod-name> -n rundeck
kubectl logs <pod-name> -n rundeck
```

### Database Connection Issues

Verify database secret and connectivity:
```bash
kubectl get secret database-password -n rundeck -o yaml
kubectl exec -it <pod-name> -n rundeck -- nc -zv your-rds-endpoint 3306
```

### Ingress/ALB Issues

Check ingress and ALB controller logs:
```bash
kubectl describe ingress -n rundeck
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### DNS Not Resolving

Check ExternalDNS logs:
```bash
kubectl logs -n kube-system deployment/external-dns
```

## Advanced Configuration

### Custom Node Selector

```yaml
nodeSelector:
  workload-type: rundeck
  environment: production
```

### Pod Anti-Affinity

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - rundeckpro
        topologyKey: kubernetes.io/hostname
```

### Resource Quotas

```yaml
resources:
  requests:
    memory: "3Gi"
    cpu: "800m"
  limits:
    memory: "3.5Gi"
    cpu: "950m"
```

## Security Best Practices

1. **Never commit sensitive values** to version control
2. **Use Kubernetes secrets** for all passwords and tokens
3. **Enable RBAC** on your EKS cluster
4. **Use IAM roles** for AWS service access (IRSA)
5. **Regularly update** Rundeck image versions
6. **Enable audit logging** in Rundeck
7. **Use SSL/TLS** for all connections
8. **Implement network policies** to restrict pod communication

## Additional Resources

- [Rundeck Documentation](https://docs.rundeck.com/)
- [Helm Documentation](https://helm.sh/docs/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## Support

For issues and questions:
- [Rundeck Community Forums](https://community.pagerduty.com/)
- [PagerDuty Support](https://support.pagerduty.com/)
- [GitHub Issues](https://github.com/rundeck/docker-zoo/issues)

## License

This Helm chart is provided as-is for deploying PagerDuty Runbook Automation. Refer to your Rundeck Enterprise license for application usage terms.
