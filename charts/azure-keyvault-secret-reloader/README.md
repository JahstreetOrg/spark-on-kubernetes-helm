# Azure KeyVault Secret Reloader

[Azure KeyVault Secret Reloader]() is used to generate .htpasswd file for Nginx basic auth, create Kubernetes Secret from its content for [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) and push original password string to Azure KeyVault.

## Introduction

This chart bootstraps an Azure KeyVault Secret Reloader CronJob, on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release --namespace kube-system .
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

The following table lists the configurable parameters of the Sealed Secrets chart and their default values.

| Parameter | Description | Default |
| ------------------------------------ |----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `nameOverride` | Provide a name in place of `prometheus-operator` |`""`|
| `fullNameOverride` | Provide a name to substitute for the full names of resources |`""`|
| `image.repository` | `azure-keyvault-secret-reloader` image repository. | `sasnouskikh/azkv-secret-reloader` |
| `image.tag` | `azure-keyvault-secret-reloader` image tag. | `2.0.61` |
| `image.pullPolicy` | Image pull policy. | `IfNotPresent` |
| `schedule` | Crontab string for this CronJob | `0 0 * * *` |
| `restartPolicy` | Restart policy for this CronJob | `OnFailure` |
| `secretName` | Kubernetes Secret name to get config for the CronJob entrypoint. See examples/secret.yaml to get a list of required keys | `""` |
| `config.*` | If secretName is not set - provide config.* values, otherwise the are omitted | `` |
| `config.sp.clientId` | Service principal ClientId to access KeyVault | `""` |
| `config.sp.clientSecret` | Service principal ClientSecret to access KeyVault | `""` |
| `config.sp.tenant` | Service principal TenantId to access KeyVault | `""` |
| `config.keyvault.name` | KeyVault name to publish generated password | `""` |
| `config.keyvault.secretName` | KeyVault secretName to publish generated password | `""` |
| `config.keyvault.subscription` | KeyVault subscription to publish generated password | `""` |
| `config.username` | Username for which to generate password | `admin` |
| `config.authSecretName` | Kubernetes Secret name to create from generated .htpasswd file | `auth-secret` |
| `config.targetNamespaces` | Space-separated list of Kubernetes Namespaces where to create Secrets from generated .htpasswd file | `{{ .Release.Namespace }}` |
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Toleration labels for pod assignment | `[]` |
| `affinity` | Affinity settings for pod assignment | `{}` |
