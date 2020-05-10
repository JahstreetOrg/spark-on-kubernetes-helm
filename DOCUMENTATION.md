# Spark on Kubernetes Cluster

### Local setup

To setup the `spark-cluster` chart locally you need:

* Instal [Minikube][minikube-install] or [Kubernetes on Docker Desktop][docker-desktop-install] for your OS
* [Install Kubectl][kubectl-install]
* [Install Helm][helm-install] and [initialize][init-helm] it (for Helm 2.x)
* Refer [helm-init.sh][helm-init-sh] for example
* Add entry to [hosts][hosts-file] file

```text
127.0.0.1 my-cluster.example.com
```

* Add and sync Helm repository `jahstreet`

```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
```

* Install [cluster-base][cluster-base-chart] chart

```bash
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
helm upgrade --install cluster-base jahstreet/cluster-base --namespace kube-system \
	--set nginx-ingress.controller.service.loadBalancerIP=127.0.0.1 \
	--set autoscaler.enabled=false \
	--set oauth2-proxy.enabled=false
```

* Install [spark-cluster][spark-cluster-chart] chart (NOTE: use release name `spark-cluster`)

```bash
helm upgrade --install spark-cluster --namespace spark-cluster jahstreet/spark-cluster \
	-f charts/spark-cluster/examples/custom-values-local.yaml
```

* Installation may take some time, wait until the `Pods` are `Running`

```bash
kubectl get pods --watch --namespace spark-cluster
```

* Go to `https://my-cluster.example.com/jupyterhub` in your browser
* Enter login `admin` and password `admin`
* `Spawn` Jupyter profile and you'll be redirected to your personal `Jupyter Notebook` once it's Up and Running
* You can find Livy UI with the clickable links to the Spark UI, logs and debug info for the `Running` Jupyter sessions at `https://my-cluster.example.com/livy`

* Install [spark-monitoring][spark-monitoring-chart] chart

```bash
helm repo update
helm upgrade --install spark-monitoring --namespace monitoring jahstreet/spark-monitoring \
	-f charts/spark-monitoring/example/custom-values-example.yaml
```

> **Note**: at present the `spark-monitoring` chart requires to be installed with the release name `spark-monitoring` to the `monitoring` namespace in order to make `Prometheus Pushgateway` service monitor work properly. Please refer `charts/spark-monitoring/values.yaml` section `pushgateway` to change that.

* Installation may take some time, wait until the `Pods` are `Running`

```bash
kubectl get pods --watch --namespace monitoring
```

* Go to `https://my-cluster.example.com/grafana` in your browser
* Login to Grafana with user `admin` and password `admin`
* Go to `Explore` page via corresponding tab on the left panel, select datasource `Loki` and choose the Kubernetes labels to get Pod logs for

<span style="display:block;text-align:center;max-width:640px">![Livy schema][grafana-explore-image]</span>

* Also you can find already pre-installed Grafana dasboards: `Spark Metrics` and `Cluster State Board`

[cluster-base-chart]: https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/cluster-base
[docker-desktop-install]: https://docs.docker.com/get-docker/
[grafana-explore-image]: images/grafana-explore-page.png
[helm-init-sh]: ./scripts/helm-init.sh
[helm-install]: https://helm.sh/docs/intro/install/
[hosts-file]: https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/
[init-helm]: #initialize-helm-for-helm-2x
[kubectl-install]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[minikube-install]: https://kubernetes.io/docs/tasks/tools/install-minikube/
[spark-cluster-chart]: https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/spark-cluster
[spark-monitoring-chart]: https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/spark-monitoring
