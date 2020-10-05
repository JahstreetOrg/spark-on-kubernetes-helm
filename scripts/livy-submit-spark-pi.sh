#!/bin/bash

set -ex

LIVY_POD_NAME=${LIVY_POD_NAME:-$1}
LIVY_POD_NAMESPACE=${LIVY_POD_NAMESPACE:-$2}

: "${LIVY_POD_NAME:?required, export it as a var or pass as 1st argument to the script}"
: "${LIVY_POD_NAMESPACE:?required, export it as a var or pass as 2nd argument to the script}"

kubectl exec $LIVY_POD_NAME --namespace $LIVY_POD_NAMESPACE -- \
  curl -s -H 'Content-Type: application/json' -X POST \
  -d '{ "name": "spark_pi",
        "numExecutors": 2,
        "conf": {
            "spark.kubernetes.container.image.pullPolicy": "Always",
            "spark.kubernetes.namespace": "'$LIVY_POD_NAMESPACE'"
        },
        "file": "local:///opt/spark/examples/jars/spark-examples_2.12-3.0.1.jar",
        "className": "org.apache.spark.examples.SparkPi",
        "args": [
            "100000"
        ]
      }' "http://localhost:8998/batches"

echo "Run kubectl port-forward $LIVY_POD_NAME --namespace $LIVY_POD_NAMESPACE 8998"
echo "# Open in browser: http://localhost:8998"
echo "Check your running job on the Livy UI and be happy!"
