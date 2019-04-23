# Helm Chart for Spark on Kubernetes monitoring with Prometheus Operator, Prometheus Pushgateway and Loki

[Prometheus](https://prometheus.io/) stack to monitor [Spark on Kubernetes](https://spark.apache.org/docs/latest/running-on-kubernetes.html) cluster and aggregate logs with [Loki](https://github.com/grafana/loki).

#### Configurations

The configurable parameters for the chart components shold be found in the appropriate repos:
- [prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
- [promehteus-pushgateway](https://github.com/helm/charts/tree/master/stable/prometheus-pushgateway)
- [loki-stack](https://github.com/grafana/loki/tree/master/production/helm/loki-stack)

Review [values.yaml](values.yaml) file to see the defaults overrides.

#### Installing the Chart

To install or upgrade the chart execute:
```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
helm upgrade --install spark-monitoring --namespace monitoring jahstreet/spark-monitoring
```

> **Note**: deploying chart to `monitoring` namespace is preferred. If you deploy to another namespace some default configs may have to be changed.
