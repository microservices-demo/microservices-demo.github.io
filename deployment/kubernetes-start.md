---
layout: default
deployDoc: false
---

## Deploying Sock Shop on any Kubernetes cluster

This explains how to deploy the Sock Shop onto any existing Kubernetes cluster.

### Pre-requisites

- Create a Kubernetes linux cluster.  For instance, see these examples:
  - AWS - [KOPS](https://github.com/kubernetes/kops)
  - Azure - [Azure Container Service](https://docs.microsoft.com/azure/container-service/container-service-kubernetes-walkthrough)
  - Google Cloud - [Google Container Engine](https://cloud.google.com/container-engine/docs/clusters/operations)
- Install and configure kubectl to connect to the cluster

### Deploy Sock Shop

1. [Clone the microservices-demo repository](https://github.com/microservices-demo/microservices-demo)
2. Go to the *deploy/kubernetes* folder
    ```
    kubectl create namespace sock-shop
    kubectl apply -f complete-demo.yaml
    ```
