#!/bin/bash

set -ex

script_path=`realpath $0`
dir_path=`dirname ${script_path}`

kubectl create -n kube-system -f ${dir_path}/cluster-admin.yaml
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --upgrade --service-account tiller

echo "Give Tiller ~1min to start. Then run your `helm upgrade --install ...` and enjoy Helming!"