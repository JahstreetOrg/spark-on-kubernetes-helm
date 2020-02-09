[![CircleCI][circle-ci-badge]][circle-ci-repo]

# Spark on Kubernetes Cluster Helm Chart

This repo contains the Helm chart for the fully functional and production ready [Spark on Kuberntes][spark-on-kubernetes-docs] cluster setup integrated with the [Spark History Server][spark-history-server-helm], [JupyterHub][jupyterhub-k8s] and [Prometheus][prometheus] stack.

Refer the [design concept][design-concept] for the implementation details.

## Getting Started

##### Initialize Helm

In order to use [Helm charts][helm] for the Spark on Kubernetes cluster deployment first we need to initialize Helm client.

```bash
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --upgrade --service-account tiller --tiller-namespace kube-system
kubectl get pods --namespace kube-system -w
# Wait until Pod `tiller-deploy-*` moves to Running state
```

##### Install Livy

The basic Spark on Kubernetes setup consists of the only [Apache Livy][livy-docs] server deployment, which can be installed with the [Livy Helm chart][livy-helm].

```bash
helm repo add jahstreet https://jahstreet.github.io/helm-charts
helm repo update
kubectl create namespace livy
helm upgrade --install livy --namespace livy jahstreet/livy \
    --set rbac.create=true # If you are running RBAC-enabled Kubernetes cluster
kubectl get pods --namespace livy -w
# Wait until Pod `livy-0` moves to Running state
```

For more advanced Spark cluster setups refer the [Documentation page][documentation-page].

##### Run Spark Job

Now when Livy is up and running we can submit Spark job via [Livy REST API][livy-rest-api].

```bash
kubectl exec --namespace livy livy-0 -- \
    curl -s -k -H 'Content-Type: application/json' -X POST \
      -d '{
            "name": "SparkPi-01",
            "className": "org.apache.spark.examples.SparkPi",
            "numExecutors": 2,
            "file": "local:///opt/spark/examples/jars/spark-examples_2.11-2.4.3.jar",
            "args": ["10000"],
            "conf": {
                "spark.kubernetes.namespace": "livy"
            }
          }' "http://localhost:8998/batches" | jq
# Record BATCH_ID from the response
```

##### Track running job

To track the running Spark job we can use all the available [Kubernetes tools][spark-on-kubernetes-debugging] and the [Livy REST API][livy-rest-api].

```bash
# Watch running Spark Pods
kubectl get pods --namespace livy -w --show-labels
# Check Livy batch status
kubectl exec --namespace livy livy-0 -- curl -s http://localhost:8998/batches/$BATCH_ID | jq
```

To configure [Ingress][kubernetes-ingress] for direct access to Livy UI and Spark UI refer the [Documentation page][documentation-page].

## Spark on Kubernetes Cluster Design Concept

### Motivation

Running [Spark on Kubernetes][spark-on-kubernetes-docs] is available since Spark `v2.3.0` release on February 28, 2018. Now it is `v2.4.5` and still lacks much comparing to the well known Yarn setups on Hadoop-like clusters.

Corresponding to the official [documentation][spark-on-kubernetes-docs] user is able to run Spark on Kubernetes via [`spark-submit` CLI script][spark-on-kubernetes-cluster-mode]. And actually it is the only in-built into Apache Spark Kubernetes related capability along with some [config options][spark-on-kubernetes-config]. [Debugging proposal][spark-on-kubernetes-debugging] from Apache docs is too poor to use it easily and available only for console based tools. Schedulers integration is not available either, which makes it too tricky to setup convenient pipelines with Spark on Kubernetes out of the box. Yarn based Hadoop clusters in turn has all the UIs, Proxies, Schedulers and APIs to make your life easier.

On the other hand the usage of Kubernetes clusters in opposite to Yarn ones has definite benefits (July 2019 comparison):

- <b>Pricing.</b> Comparing the similar cluster setups on Azure Cloud shows that [AKS][azure-aks] is about 35% cheaper than [HDInsight Spark][azure-hdinsight-spark].
- <b>Scaling.</b> Kubernetes cluster in Cloud support elastic autoscaling with many cool related features alongside, eg: Nodepools. Scaling of Hadoop clusters is far not as fast though, can be done either [manually][azure-hdinsight-manual-scaling] or [automatically][azure-hdinsight-auto-scaling] (on July 2019 was in preview).
- <b>Integrations.</b> You can run any workloads in Kubernetes cluster wrapped into the Docker container. But do you know anyone who has ever written Yarn App in the modern world?
- <b>Support.</b> You don't have a full control over the cluster setup provided by Cloud and usually there are no latest versions of software available for months after the release. With Kubernetes you can build image on your own.
- <b>Other Kuebernetes pros.</b> CI/CD with Helm, Monitoring stacks ready for use in-one-button-click, huge popularity and community support, good tooling and of course HYPE.

All that makes much sense to try to improve Spark on Kubernetes usability to take the whole advantage of modern Kubernetes setups in use.

### Design concept

The heart of all the problems solution is [Apache Livy][livy-docs]. Apache Livy is a service that enables easy interaction with a Spark cluster over a REST interface. It is supported by [Apache Incubator][apache-incubator] community and [Azure HDInsight][azure-hdinsight-livy] team, which uses it as a first class citizen in their Yarn cluster setup and does many integrations with it. Watch [Spark Summit 2016, Cloudera and Microsoft, Livy concepts and motivation][youtube-azure-livy] for the details.

The cons is that Livy is written for Yarn. But Yarn is just Yet Another resource manager with containers abstraction adaptable to the Kubernetes concepts. Livy is fully open-sourced as well, its codebase is RM aware enough to make Yet Another One implementation of it's interfaces to add Kubernetes support. So why not!? Check the [WIP PR][livy-588] with Kubernetes support proposal for Livy.

The high-level architecture of Livy on Kubernetes is the same as for Yarn.

<span style="display:block;text-align:center;max-width:640px">![Livy schema][image-livy-schema]</span>

Livy server just wraps all the logic concerning interaction with Spark cluster and provides simple [REST interface][livy-rest-api].

<details><summary><b>[EXPAND]</b> For example, to submit Spark Job to the cluster you just need to send `POST /batches` with JSON body containing Spark config options, mapped to `spark-submit` script analogous arguments.</summary>
<p>

```bash
$SPARK_HOME/bin/spark-submit \
    --master k8s://https://<k8s-apiserver-host>:<k8s-apiserver-port> \
    --deploy-mode cluster \
    --name SparkPi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=5 \
    --conf spark.kubernetes.container.image=<spark-image> \
    local:///path/to/examples.jar
 
# Has the similar effect as calling Livy via REST API
 
curl -H 'Content-Type: application/json' -X POST \
  -d '{
        "name": "SparkPi",
        "className": "org.apache.spark.examples.SparkPi",
        "numExecutors": 5,
        "conf": {
          "spark.kubernetes.container.image": "<spark-image>"
        },
        "file": "local:///path/to/examples.jar"
      }' "http://livy.endpoint.com/batches"
```
</p></details>

Under the hood Livy parses POSTed configs and does `spark-submit` for you, bypassing other defaults configured for the Livy server.

After the job submission Livy discovers Spark Driver Pod scheduled to the Kubernetes cluster with Kubernetes API and starts to track its state, cache Spark Pods logs and details descriptions making that information available through Livy REST API, builds routes to Spark UI, Spark History Server, Monitoring systems with [Kubernetes Ingress][kubernetes-ingress] resources, [Nginx Ingress Controller][nginx-ingress] in particular and displays the links on Livy Web UI.

Providing REST interface for Spark Jobs orchestration Livy allows any number of integrations with Web/Mobile apps and services, easy way of setting up flows via jobs scheduling frameworks.

Livy has in-built lightweight Web UI, which makes it really competitive to Yarn in terms of navigation, debugging and cluster discovery.

<span style="display:block;text-align:center;max-width:640px">![Livy home][image-livy-home]</span>
<span style="display:block;text-align:center;max-width:640px">![Livy sessions][image-livy-session]</span>
<span style="display:block;text-align:center;max-width:640px">![Livy logs][image-livy-logs]</span>
<span style="display:block;text-align:center;max-width:640px">![Livy diagnostics][image-livy-diagnostics]</span>

Livy supports interactive sessions with Spark clusters allowing to communicate between Spark and application servers, thus enabling the use of Spark for interactive web/mobile applications. Using that feature Livy integrates with [Jupyter Notebook][jupyter] through [Sparkmagic kernel][sparkmagic] out of box giving user elastic Spark exploratory environment in Scala and Python. Just deploy it to Kubernetes and use!

<span style="display:block;text-align:center;max-width:640px">![Livy schema][image-sparkmagic-schema]</span>

On top of Jupyter it is possible to set up [JupyterHub][jupyterhub], which is a multi-user Hub that spawns, manages, and proxies multiple instances of the single-user Jupyter notebook servers. Follow the video [PyData 2018, London, JupyterHub from the Ground Up with Kubernetes - Camilla Montonen][youtube-jupyterhub] to learn the details of the implementation. JupyterHub provides a way to setup auth through Azure AD with [AzureAdOauthenticator plugin][jupyterhub-azure-ad-oauthenticator] as well as many other Oauthenticator plugins.

<span style="display:block;text-align:center;max-width:640px">![Jupyterhub architecture][image-jupyterhub-architecture]</span>

Monitoring setup of Kubernetes cluster itself can be done with [Prometheus Operator][prometheus-operator-helm] stack with [Prometheus Pushgateway][prometheus-pushgateway-helm] and [Grafana Loki][grafana-loki-helm] using a combined [Helm chart][spark-monitoring-helm], which allows to do the work in one-button-click. Learn more about the stack from videos:
- [End to end monitoring with the Prometheus Operator][youtube-prometheus]
- [Grafana Loki: Like Prometheus, But for logs. - Tom Wilkie, Grafana Labs][youtube-loki]

The overall monitoring architecture solves pull and push model of metrics collection from the Kubernetes cluster and the services deployed to it. [Prometheus Alertmanager][prometheus-alertmanager] gives an interface to setup alerting system.

<span style="display:block;text-align:center;max-width:640px">![Prometheus architecture][image-prometheus-architecture]</span>
<span style="display:block;text-align:center;max-width:640px">![Prometheus operator schema][image-prometheus-operator-schema]</span>

With the help of [JMX Exporter][jmx-exporter] or [Pushgateway Sink][prometheus-sink] we can get Spark metrics inside the monitoring system. [Grafana Loki][grafana-loki] provides out-of-box logs aggregation for all Pods in the cluster and natively integrates with [Grafana][grafana]. Using [Grafana Azure Monitor datasource][grafana-azuremonitor] and [Prometheus Federation][prometheus-federation] feature you can setup complex global monitoring architecture for your infrastructure.

<span style="display:block;text-align:center;max-width:640px">![Global monitoring][image-global-monitoring]</span>

References:
- [[LIVY-588][WIP]: Full support for Spark on Kubernetes][livy-588]
- [Jupyter Sparkmagic kernel to integrate with Apache Livy][sparkmagic]
- [Spark Summit 2016, Cloudera and Microsoft, Livy concepts and motivation][youtube-livy]
- [PyData 2018, London, JupyterHub from the Ground Up with Kubernetes - Camilla Montonen][youtube-jupyterhub]
- [End to end monitoring with the Prometheus Operator][youtube-prometheus]
- [Grafana Loki: Like Prometheus, But for logs. - Tom Wilkie, Grafana Labs][youtube-loki]
- [NGINX conf 2018, Using NGINX as a Kubernetes Ingress Controller][youtube-nginx]


[apache-incubator]: https://incubator.apache.org/

[azure-aks]: https://docs.microsoft.com/en-us/azure/aks/
[azure-hdinsight-auto-scaling]: https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-autoscale-clusters
[azure-hdinsight-livy]: https://docs.microsoft.com/en-us/azure/hdinsight/spark/apache-spark-livy-rest-interface
[azure-hdinsight-manual-scaling]: https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-scaling-best-practices
[azure-hdinsight-spark]: https://docs.microsoft.com/en-us/azure/hdinsight/spark/apache-spark-overview

[circle-ci-badge]: https://circleci.com/gh/jahstreet/spark-on-kubernetes-helm.svg?style=svg
[circle-ci-repo]: https://circleci.com/gh/jahstreet/spark-on-kubernetes-helm

[documentation-page]: DOCUMENTATION.md
[design-concept]: #spark-on-kubernetes-cluster-design-concept

[grafana]: https://grafana.com/
[grafana-azuremonitor]: https://grafana.com/docs/features/datasources/azuremonitor/
[grafana-loki]: https://grafana.com/loki
[grafana-loki-helm]: https://github.com/grafana/loki/tree/master/production/helm

[helm]: https://helm.sh/docs/

[jmx-exporter]: https://github.com/prometheus/jmx_exporter

[image-global-monitoring]: images/global-monitoring.png
[image-jupyterhub-architecture]: images/jupyterhub-architecture.png
[image-livy-diagnostics]: images/livy-diagnostics.png
[image-livy-home]: images/livy-home.png
[image-livy-logs]: images/livy-logs.png
[image-livy-schema]: images/livy-schema.jpg
[image-livy-session]: images/livy-session.png
[image-prometheus-architecture]: images/prometheus-architecture.png
[image-prometheus-operator-schema]: images/prometheus-operator-schema.jpg
[image-sparkmagic-schema]: images/sparkmagic-schema.png

[jupyter]: https://jupyter.readthedocs.io/en/latest/
[jupyterhub]: (https://jupyterhub.readthedocs.io/en/stable/)
[jupyterhub-azure-ad-oauthenticator]: https://github.com/jupyterhub/oauthenticator#azure-setup
[jupyterhub-k8s]: https://zero-to-jupyterhub.readthedocs.io/en/latest/

[kubernetes-ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/

[livy-588]: https://github.com/apache/incubator-livy/pull/167
[livy-docs]: https://livy.incubator.apache.org/
[livy-helm]: charts/livy
[livy-rest-api]: https://livy.incubator.apache.org/docs/latest/rest-api.html

[nginx-ingress]: https://github.com/kubernetes/ingress-nginx

[prometheus]: https://prometheus.io/
[prometheus-alertmanager]: https://prometheus.io/docs/alerting/alertmanager/
[prometheus-federation]: https://prometheus.io/docs/prometheus/latest/federation/
[prometheus-operator-helm]: https://github.com/helm/charts/tree/master/stable/prometheus-operator
[prometheus-pushgateway-helm]: https://github.com/helm/charts/tree/master/stable/prometheus-pushgateway
[prometheus-sink]: https://github.com/banzaicloud/spark-metrics/blob/master/PrometheusSink.md

[spark-history-server-helm]: https://github.com/helm/charts/tree/master/stable/spark-history-server
[spark-monitoring-helm]: https://github.com/jahstreet/spark-on-kubernetes-helm/tree/master/charts/spark-monitoring
[spark-on-kubernetes-cluster-mode]: https://spark.apache.org/docs/latest/running-on-kubernetes.html#cluster-mode
[spark-on-kubernetes-config]: https://spark.apache.org/docs/latest/running-on-kubernetes.html#spark-properties
[spark-on-kubernetes-debugging]: https://spark.apache.org/docs/latest/running-on-kubernetes.html#introspection-and-debugging
[spark-on-kubernetes-docs]: https://spark.apache.org/docs/latest/running-on-kubernetes.html
[spark-on-yarn-docs]: https://spark.apache.org/docs/latest/running-on-yarn.html

[sparkmagic]: https://github.com/jupyter-incubator/sparkmagic

[youtube-azure-livy]: https://www.youtube.com/watch?v=C_3iEf_KNv8&t=836s
[youtube-jupyterhub]: https://www.youtube.com/watch?v=rVOLdTE5bg0
[youtube-livy]: https://www.youtube.com/watch?v=C_3iEf_KNv8&t=836s
[youtube-loki]: https://www.youtube.com/watch?v=CQiawXlgabQ
[youtube-nginx]: https://www.youtube.com/watch?v=AXZr2OC8Unc
[youtube-prometheus]: https://www.youtube.com/watch?v=5Jr1v9mWnJc





