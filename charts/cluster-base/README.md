# Helm Chart for Kubernetes cluster base services

#### Configurations

- Configure:
  - Role-based access control (RBAC): `ServiceAccount`, `ClusterRole`, `Role`, `ClusterRoleBinding`, and `RoleBinding` resources.
  - `StorageClass` resources.
  - Certificates and Issuers: `ClusterIssuer`, `Issuer`, `Certificate` resources for use by *cert-manager*, *ingress-nginx*, and others.

The configurable parameters for the dependent charts shold be found in the appropriate repos:
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx)
- [cert-manager](https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager)
- [oauth2-proxy](https://github.com/helm/charts/tree/master/stable/oauth2-proxy)
- [cluster-autoscaler](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler)

Review [values.yaml](values.yaml) file and [examples](examples/) folder to see the defaults overrides.

#### Installing the Chart

* Install [Certmanager CRDs](https://cert-manager.io/docs/installation/kubernetes/#installing-with-regular-manifests)

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml
```

* Install the chart

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install cluster-base --namespace kube-system jahstreet/cluster-base
```
