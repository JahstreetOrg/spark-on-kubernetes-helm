# Spark on Kubernetes Cluster

### Local setup

To setup the `spark-cluster` chart locally you need:

* Instal [Minikube][minikube-install] or [Kubernetes on Docker Desktop][docker-desktop-install] for your OS

  * Supported Kubernetes versions 1.11.0 - 1.18.0.

```bash
minikube start --kubernetes-version=1.18.0 --cpus=12 --memory=14g
```

* [Install Kubectl][kubectl-install]
* [Install Helm][helm-install] and [initialize][init-helm] it (for Helm 2.x)

```bash
export TILLER_NAMESPACE=kube-system
kubectl create -n kube-system -f scripts/cluster-admin.yaml
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --upgrade --service-account tiller
```

* Add and sync Helm repository `jahstreet`

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart
helm repo add loki https://grafana.github.io/loki/charts
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
```

* Run in a separate terminal `minikube tunnel`

* Install [cluster-base][cluster-base-chart] chart

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml
helm upgrade --install cluster-base jahstreet/cluster-base --namespace kube-system
```

* Check the Nginx Ingress Controller load balancer external IP

```bash
kubectl get service cluster-base-ingress-nginx-controller --namespace kube-system
```

* Add entry to [hosts][hosts-file] file

```text
<load-balancer-external-IP> my-cluster.example.com
```

* Install [spark-cluster][spark-cluster-chart] chart (NOTE: use release name `spark-cluster`)

```bash
helm upgrade --install spark-cluster --namespace spark-cluster jahstreet/spark-cluster \
    --timeout 600 \
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
* Try out notebooks in `examples/` folder

* Install [spark-monitoring][spark-monitoring-chart] chart

```bash
helm upgrade --install spark-monitoring --namespace monitoring jahstreet/spark-monitoring \
    --timeout 600 \
    -f charts/spark-monitoring/examples/custom-values-example.yaml
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
