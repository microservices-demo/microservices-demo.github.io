---
layout: default
deployDoc: true
---

## Kubernetes
To deploy Prometheus & Grafana and to setup all the nice graphs that we got ready
for you, simply:

```
$ kubectl create -f ./deploy/kubernetes/manifests-monitoring
```

Assuming that used `minikube` to deploy your Kubernetes cluster, to get the URL of
the services:


#### Prometheus
```
$ minikube service list | grep prometheus
| monitoring  | prometheus           | http://192.168.99.100:31090 |
```

#### Grafana
```
$ minikube service list | grep grafana
| monitoring  | grafana              | http://192.168.99.100:31300 |
```
