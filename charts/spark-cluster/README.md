# Helm Chart for Spark on Kubernetes cluster with Apache Livy, Jupyter notebooks and Spark History Server

#### Configurations

The configurable parameters for the Spark cluster components shold be found in the appropriate repos:
- [livy](https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/livy)
- [jupyter-sparkmagic](https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/jupyter-sparkmagic)
- [spark-history-server](https://github.com/helm/charts/tree/master/stable/spark-history-server)

Review [values.yaml](values.yaml) file to see the defaults overrides.

#### Installing the Chart

To install or upgrade the chart execute:
```bash
$ helm repo add jahstreet https://jahstreet.github.io/helm-charts
$ helm repo update
$ helm upgrade --install spark-cluster --namespace spark-cluster jahstreet/spark-cluster
```