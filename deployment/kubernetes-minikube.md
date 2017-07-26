---
layout: default
---

## Sock Shop on Minikube

This demo demonstrates running the Sock Shop on Minikube.

### Pre-requisites
* Install [Minikube](https://github.com/kubernetes/minikube)
* Install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/)

### Clone the microservices-demo repo 

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

### Start Minikube

You can start Minikube by running:

```
minikube start --memory 8192
```

Check if it's running with `minikube status`, and make sure the Kubernetes dashboard is running on http://192.168.99.100:30000.

Approximately 4 GB of RAM is required to run all the services.

##### *(Optional)* Run with Fluentd + ELK based logging

If you want to run the application using a more advanced logging setup based on Fluentd + ELK stack, there are 2 requirements:
* assign at least 6 GB of memory to the minikube VM
* increase vm.max_map_count to 262144 or higher (Required because Elasticsearch will not start if it detects a value lower than 262144).

```
minikube delete
minikube config set memory 6144
minikube start
minikube ssh
```

Once logged into the VM:

```
$ sudo sysctl -w vm.max_map_count=262144
```

After these settings are done you can start the logging manifests.

```
kubectl create -f deploy/kubernetes/manifests-logging
```

You should be able to see the Kibana dashboard at http://192.168.99.100:31601.

### Deploy Sock Shop

Deploy the Sock Shop application on Minikube

```
kubectl create -f deploy/kubernetes/manifests/sock-shop-ns.yaml -f deploy/kubernetes/manifests
```

To start Opentracing run the following command after deploying the sock shop
```
kubectl apply -f deploy/kubernetes/manifests-zipkin/zipkin-ns.yaml -f deploy/kubernetes/manifests-zipkin
```

Wait for all the Sock Shop services to start:

```
kubectl get pods --namespace="sock-shop"
```

### Check the Sock Shop webpage

Once the application is deployed, navigate to http://192.168.99.100:30001 to see the Sock Shop home page.

### Opentracing

Zipkin is part of the deployment and has been written into some of the services.  While the system is up you can view the traces in
Zipkin at http://192.168.99.100:30002.  Currently orders provide the most comprehensive traces, but this requires a user to place an order.

### Run tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud. You should
also check what ip your minikube instance has been assigned and use that in the load test.

```
minikube ip
docker run --rm weaveworksdemos/load-test -d 5 -h 192.168.99.100:30001 -c 2 -r 100
```

### Uninstall the Sock Shop application

```
kubectl delete -f deploy/kubernetes/manifests/sock-shop-ns.yaml -f deploy/kubernetes/manifests
```

If you don't need the Minikube instance anymore you can delete it by running:

```
minikube delete
```
