# Helm Chart for Spark on Kubernetes cluster

#### Configurations

The configurable parameters for the Spark cluster components shold be found in the appropriate repos:
- [livy](https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/livy)
- [spark-history-server](https://github.com/helm/charts/tree/master/stable/spark-history-server)
- [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/tree/master/jupyterhub)

Review [values.yaml](values.yaml) file and [examples](examples/) folder to see the defaults overrides.

#### Installing the Chart

To install or upgrade the chart execute:
```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install spark-cluster --namespace spark-cluster jahstreet/spark-cluster
```

> **Note**: by default Spark History Server and JupyterHub are not installed. Configure them appropriatelly before installing with chart.

> **Note**: make sure to configure Livy spark-defaults to write Spark event logs to the place configured in History Server.
