---
layout: default
deployDoc: true
---

## Micro Sock on Docker Compose and Weave Cloud

Micro Sock is a small application that simulates a microservice. It listens for connections and initiates connection to other services specified as a parameter on the command line, and exchanges messages with those services. It is ideal for building a quick topology of services that talk to each other. 

The instructions on this page will allow you to get started with a Docker Compose setup that uses multiple micro-sock containers to build a topology that resembles the other Sock Shop deployments. The advantage is that that the required download is only 5 MB and the whole setup starts very fast.

### Pre-requisites

- Install [Docker](https://www.docker.com/products/overview)
- Install [Docker Compose](https://docs.docker.com/compose/install/)
- Install [Weave Scope](https://www.weave.works/install-weave-scope/)

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```
<!-- deploy-doc-hidden pre-install

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq python-pip build-essential python-dev
    pip install docker-compose

-->

### Launch Weave Scope

Get a token by [registering on Weave Cloud](http://cloud.weave.works/). Once you have the token you can download and start the Scope instance.

    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch --service-token=<token>

### Provision infrastructure

<!-- deploy-doc-start create-infrastructure -->

    docker-compose -f deploy/micro-sock/docker-compose.yaml up -d

<!-- deploy-doc-end -->

### Check Weave Cloud

Once you started the application using Docker Compose, you can visit [Weave Cloud](http://cloud.weave.works/) to see how the containers are connected to each other. You should be seeing something like this:

![Micro Sock in Scope](https://github.com/microservices-demo/microservices-demo.github.io/raw/master/assets/micro-sock-scope.png)

### Cleaning up

<!-- deploy-doc-start destroy-infrastructure -->

    docker-compose -f deploy/micro-sock/docker-compose.yaml down

<!-- deploy-doc-end -->