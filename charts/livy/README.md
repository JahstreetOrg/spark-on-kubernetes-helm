# Helm Chart for Apache Livy server to run Spark on Kubernetes

[Apache Livy](https://livy.incubator.apache.org/) server to run  [Spark on Kubernetes](https://spark.apache.org/docs/latest/running-on-kubernetes.html).
[PR for LIVY-588](https://github.com/apache/incubator-livy/pull/167) on integration with Kubernetes.

#### Configurations

The following tables lists the configurable parameters of the Apache Livy server chart and their default values.

| Parameter                            | Description                                                      |Default                                                                                                                         |
| ------------------------------------ |----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| image.repository | Repository for Livy | `sasnouskikh/livy` |
| image.tag | Tag for Livy | `0.8.0-incubating-spark_3.0.1_2.12-hadoop_3.2.0_cloud` |
| image.pullPolicy | Pull policy for Livy | `IfNotPresent` |
| nameOverride | Provide a name in place of livy | `""` |
| fullnameOverride | Provide a name to substitute for the full names of resources | `""` |
| rbac.create | Whether to create RBAC resources | `false` |
| serviceAccount.create | Whether to create Livy ServiceAccount | `true` |
| serviceAccount.name | The name of the ServiceAccount to use for Livy. If not set and `create` is true, a name is generated using the `fullname` template | `""` |
| sparkServiceAccount.create | Whether to create Spark ServiceAccount in `.Release.Namespace` | `true` |
| sparkServiceAccount.name | The name of the ServiceAccount to use for Spark. If not set and `create` is true, a name is generated using the `livy.fullname` template with `-spark` suffix| `""` |
| service.type | Livy Service type | `ClusterIP` |
| service.port | Livy Service port | `80` |
| ingress.enabled | Whether to create Ingress resource for Livy Service | `false` |
| ingress.annotations | Ingress annotations | `{}` |
| ingress.path | Ingress path | `/` |
| ingress.hosts | Ingress hosts FQDN list | `["livy.local"]` |
| ingress.tls | Ingress tls spec | `[]` |
| imagePullSecrets | List of imagePullSecret names to use to pull Livy image from private repo | `[]` |
| resources | Define resources requests and limits for Livy containers | `{}` |
| nodeSelector | Define which Nodes Livy Pods should be scheduled on | `{}` |
| tolerations | Define Livy Pods tolerations | `[]` |
| affinity | Define Livy Pods affinity rules | `{}` |
| persistence.enabled | Whether to enable sessions dir persistence | `false` |
| persistence.subPath | PVC subpath to mount to sessions dir | `""` |
| persistence.existingClaim | If defined, will use the existing PVC and will not create a new one | `""` |
| persistence.storageClass | If defined, storageClassName: <storageClass>, if set to "-", storageClassName: "", which disables dynamic provisioning, if undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner | `""` |
| persistence.size | PVC size | `20Gi` |
| persistence.annotations | PVC additional annotations | `{}` |
| env.* | Additional envs to set to Livy container (see [values.yaml](values.yaml) for examples) | `{see values.yaml}` |
| envFrom.* | Additional envs to set to Livy from Kubernetes ConfigMap's or Secret's (see [values.yaml](values.yaml) for examples) | `[]` |
| livyConf.* | Additional livy.conf entries to set from mounted Kubernetes ConfigMap or Secret (see [values.yaml](values.yaml) for examples) | `{}` |
| livyClientConf.* | Additional livy-client.conf entries to set from mounted Kubernetes ConfigMap or Secret (see [values.yaml](values.yaml) for examples) | `{}` |
| sparkDefaultsConf.* | Additional spark-defaults.conf entries to set from mounted Kubernetes ConfigMap or Secret (see [values.yaml](values.yaml) for examples) | `{}` |

#### Installing the Chart

To install or upgrade the chart execute:
```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install livy --namespace livy jahstreet/livy
```

#### Customizing Livy server
Apache Livy container is fully customizable through environment variables.
On startup Livy entrypoint reads environment variables and writes its values to the corresponding configs:
- livy.conf: env format `LIVY_LIVY_<config_key_mask>=<config_value>`
- spark-defaults.conf: env format `LIVY_SPARK_<config_key_mask>=<config_value>`
- livy-client.conf: env format `LIVY_CLIENT_<config_key_mask>=<config_value>`

Config key mask rules:
1) KEY_MASK_WITH0DASH_WITH1UPPERCASE -> toLowerCase : key_mask_with0dash_with1uppercase
2) key_mask_with0dash_with1uppercase -> replaceUnderscoresToDots : key.mask.with0dash.with1uppercase
3) key.mask.with0dash.with1uppercase -> replaceZeroesToDashes : key.mask.with-dash.with1uppercase
4) key.mask.with-dash.with1uppercase -> triggerUppercasingMarkedByOnes : key.mask.with-dash.withUppercase

Examples:
- livy.conf: LIVY_LIVY_SERVER_SESSION_MAX0CREATION -> livy.server.session.max-creation
- spark-defaults.conf: LIVY_SPARK_EVENT1LOG_DIR -> spark.eventLog.dir
- livy-client.conf: LIVY_CLIENT_RSC_RPC_SERVER_ADDRESS -> livy.rsc.rpc.server.address

Out of that you can mount config entries as files to the following directories:
- LIVY_CONFIG_MOUNT_DIR=${LIVY_CONFIG_MOUNT_DIR:-/etc/config}
- LIVY_SECRET_MOUNT_DIR=${LIVY_SECRET_MOUNT_DIR:-/etc/secret}

Example of the mounted entry:
```bash
cat /etc/config/livy.conf/livy.server.session.max-creation
# output:
# 10

cat /etc/secret/spark-defaults.conf/spark.eventLog.dir
# output:
# wasbs:///history-server
```
> **Tip**: refer [entrypoint.sh](https://github.com/jahstreet/spark-on-kubernetes-docker/blob/master/livy/0.8.0-incubating-spark_3.0.1_2.12-hadoop_3.2.0_cloud/entrypoint.sh) for details.
