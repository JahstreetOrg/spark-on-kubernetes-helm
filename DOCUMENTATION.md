# Spark on Kubernetes Cluster

### Local setup

To setup the `spark-cluster` chart locally you need:

* Instal [Minikube][minikube-install] or [Kubernetes on Docker Desktop][docker-desktop-install] for you OS
* [Install Kubectl][kubectl-install]
* [Install Helm][helm-install] and initialize it (for Helm 2.x)
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

* Install `spark-cluster` chart (NOTE: use release name `spark-cluster`)

```bash
helm upgrade --install spark-cluster --namespace spark-cluster jahstreet/spark-cluster -f charts/spark-cluster/example/custom-values-local.yaml
```

* Installation may take some time, wait until the `Pods` are `Running`

```bash
kubectl get pods --watch --namespace spark-cluster
```

* Go to `https://my-cluster.example.com/jupyterhub` in your browser
* Enter login `admin` and password `admin`
* `Spawn` Jupyter profile and you'll be redirected to your personal `Jupyter Notebook` once it's Up and Running
* You can find Livy UI with the clickable links to the Spark UI, logs and debug info for the `Running` Jupyter sessions at `https://my-cluster.example.com/livy`

[cluster-base-chart]: https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/cluster-base
[docker-desktop-install]: https://docs.docker.com/get-docker/
[helm-install]: https://helm.sh/docs/intro/install/
[hosts-file]: https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/
[kubectl-install]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[minikube-install]: https://kubernetes.io/docs/tasks/tools/install-minikube/
