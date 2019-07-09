# Helm Chart for Azure KeyVault Secret Reloader to refresh Nginx basic auth .htpasswd file to Kubernetes secret and Azure KeyVault secret.

[Azure KeyVault Secret Reloader]() is [Kubernetes CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) used to generate [.htpasswd](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/) file for Nginx basic auth, create Kubernetes Secret from its content for [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) and push original password string to [Azure KeyVault](https://docs.microsoft.com/en-us/azure/key-vault/) Secrets.

#### AAD Service Principal requirements
To configure access of the CronJob to the KeyVault perform the following steps:
- Create AAD WebApp and get its creds
- Add to the Keyvault `Access policies` this WebApp with Get, List, Set `Secret permissions`

#### Configurations

The following table lists the configurable parameters of the Azure KeyVault Secret Reloader chart and their default values.

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
| `servicePrincipal.*` | If secretName is not set - provide servicePrincipal.* values, otherwise the are omitted | `` |
| `servicePrincipal.clientId` | Service principal ClientId to access KeyVault | `""` |
| `servicePrincipal.clientSecret` | Service principal ClientSecret to access KeyVault | `""` |
| `servicePrincipal.tenant` | Service principal TenantId to access KeyVault | `""` |
| `keyVault.name` | KeyVault name to publish generated password | `""` |
| `keyVault.secretName` | KeyVault secretName to publish generated password to | `""` |
| `keyVault.subscription` | KeyVault subscription | `""` |
| `username` | Username for which to generate password | `admin` |
| `authSecretName` | Kubernetes Secret name to create from generated .htpasswd file | `auth-secret` |
| `namespaces` | Space-separated list of Kubernetes Namespaces where to create Secrets from generated .htpasswd file | `{{ .Release.Namespace }}` |
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Toleration labels for pod assignment | `[]` |
| `affinity` | Affinity settings for pod assignment | `{}` |

#### Installing the Chart

To install or upgrade the chart execute:
```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install azure-keyvault-secret-reloader --namespace kube-system jahstreet/azure-keyvault-secret-reloader
```