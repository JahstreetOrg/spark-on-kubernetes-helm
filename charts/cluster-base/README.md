# Helm Chart for Kubernetes cluster base services

#### Configurations

- Configure:
  - Role-based access control (RBAC): `ServiceAccount`, `ClusterRole`, `Role`, `ClusterRoleBinding`, and `RoleBinding` resources.
  - `StorageClass` resources.
  - Certificates and Issuers: `ClusterIssuer`, `Issuer`, `Certificate` resources for use by *cert-manager*, *nginx-ingress*, and others.

The configurable parameters for the dependent charts shold be found in the appropriate repos:
- [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
- [cert-manager](https://github.com/helm/charts/tree/master/stable/cert-manager)
- [oauth2-proxy](https://github.com/helm/charts/tree/master/stable/oauth2-proxy)

> **Tip**: refer [examples](examples/) folder or [values.yaml](values.yaml) for some details and default configs
