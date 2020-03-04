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
- [cluster-autoscaler](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler)

> **Tip**: refer [examples](examples/) folder or [values.yaml](values.yaml) for some details and default configs

#### Installing the Chart

Install [Certmanager CRDs](https://github.com/helm/charts/tree/master/stable/cert-manager#installing-the-chart) and label the chart `namespace`
```bash
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
```

Install the chart:
```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install cluster-base --namespace kube-system jahstreet/cluster-base
```
