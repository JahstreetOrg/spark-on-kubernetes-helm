# Helm Chart for Jupyter notebooks with sparkmagic plugin for Apache Livy integration

[Jupyter](https://jupyter.org/) notebooks with [sparkmagic](https://github.com/jupyter-incubator/sparkmagic) plugin provides a web UI for interactive work with remote Spark clusters through [Livy](https://livy.incubator.apache.org/), a Spark REST server.

#### Configurations

The following tables lists the configurable parameters of the jupyter-sparkmagic chart and their default values.

Note that the default image `sasnouskikh/jupyter:4.4.0-sparkmagic_0.12.6` is built using this [repo](https://github.com/jahstreet/spark-on-kubernetes-docker/tree/master/jupyter).

| Parameter                            | Description                                                      |Default                                                                                                                         |
| ------------------------------------ |----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| strategy | Kubernetes Deployment update strategy spec | `{}` |
| image.repository | Repository for Jupyter with sparkmagic image | `sasnouskikh/jupyter` |
| image.tag | Tag for Jupyter with sparkmagic image | `4.4.0-sparkmagic_0.12.6` |
| image.pullPolicy | Pull policy for Jupyter with sparkmagic image | `IfNotPresent` |
| nameOverride | Provide a name in place of jupyter | `""` |
| fullnameOverride | Provide a name to substitute for the full names of resources | `""` |
| livyEndpoint | Livy server endpoint to configure sparkmagic plugin | `""` |
| protocol | Protocol to access Jupyter used to build links on Web UI | `http` |
| host | FQDN host to access Jupyter used to build links on Web UI | `""` |
| baseUrl | Base URL for Jupyter server | `"/"` |
| service.type | Jupyter Service type | `ClusterIP` |
| service.port | Jupyter Service port | `80` |
| ingress.enabled | Whether to create Ingress resource for Jupyter Service | `false` |
| ingress.annotations | Ingress annotations | `{}` |
| ingress.path | Ingress path | `/` |
| ingress.hosts | Ingress hosts FQDN list | `["jupyter.local"]` |
| ingress.tls | Ingress tls spec | `[]` |
| imagePullSecrets | List of imagePullSecret names to use to pull Jupyter image from private repo | `[]` |
| resources | Define resources requests and limits for Jupyter containers | `{}` |
| nodeSelector | Define which Nodes Jupyter Pods should be scheduled on | `{}` |
| tolerations | Define Jupyter Pods tolerations | `[]` |
| affinity | Define Jupyter Pods affinity rules | `{}` |
| notebooks.default.fromDir | Chart repo directory where to look for default notebooks | `"notebooks/default"` |
| persistence.enabled | Whether to enable notebooks dir persistense | `false` |
| persistence.subPath | PVC subpath to mount to notebooks dir | `""` |
| persistence.existingClaim | If defined, will use the existing PVC and will not create a new one | `""` |
| persistence.storageClass | If defined, storageClassName: <storageClass>, if set to "-", storageClassName: "", which disables dynamic provisioning, if undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner | `""` |
| persistence.size | PVC size | `20Gi` |
| persistence.annotations | PVC additional annotations | `{}` |
| env.* | Additional envs to set to Jupyter container (see [values.yaml](values.yaml) for examples) | `{}` |
| envFrom.* | Additional envs to set to Jupyter from Kubernetes ConfigMap's or Secret's (see [values.yaml](values.yaml) for examples) | `[]` |
| args.* | Additional args to Jupyter entrypoint command | `{auth:["--NotebookApp.token=''"]}` |

> **Note**: `livyEndpoint` is the required parameter!

#### Installing the Chart

To install or upgrade the chart execute:
```bash
$ helm repo add jahstreet https://jahstreet.github.io/helm-charts
$ helm repo update
$ helm upgrade --install jahstreet/jupyter-sparkmagic \
    --namespace jupyter-sparkmagic \
    --set livyEndpoint=<livy-svc-name>.<livy-namespace>.svc.cluster.local:<livy-svc-port>
```
