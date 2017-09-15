---
layout: default
deployDoc: true
---

## Sock Shop via Docker Compose

The Sock Shop application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.

### Networking

In this version we create a Docker network and DNS is achieved by using the internal Docker DNS, which reads network alias entries provided by docker-compose.

### Pre-requisites

- Install [Docker](https://www.docker.com/products/overview)
- Install [Docker Compose](https://docs.docker.com/compose/install/)
- *(Optional)* Install [Weave Scope](https://www.weave.works/install-weave-scope/)

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```
<!-- deploy-doc-hidden pre-install

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq python-pip build-essential python-dev
    pip install docker-compose

-->


### *(Optional)* Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch --service-token=<token>

### Provision infrastructure

<!-- deploy-doc-start create-infrastructure -->

    docker-compose -f deploy/docker-compose/docker-compose.yml up -d

<!-- deploy-doc-end -->

##### *(Optional)* Run with Fluentd logging

If you want to run the application using a more advanced logging setup based on Fluentd + ELK stack, you can add the logging compose file
to override some settings and add some extra containers:

```
docker-compose -f deploy/docker-compose/docker-compose.yml -f deploy/docker-compose/docker-compose.logging.yml up -d
```

Once deployed, you should be able to reach Kibana on http://localhost:5601.

### Run tests

There's a load test provided as a service in this compose file. For more information see [Load Test](#loadtest). 
It will run when the compose is started up, after a delay of 60s. This is a load test provided to simulate user traffic to the application. 
This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud. 

<!-- deploy-doc-hidden run-tests

    docker run -\-rm -t -\-net=dockercompose_default weaveworksdemos/healthcheck:snapshot -s user,catalogue,queue-master,carts,shipping,payment,orders -d 90 -r 5
    if [ $? -ne 0 ]; then
        exit 1;
    fi

-->

### Cleaning up

<!-- deploy-doc-start destroy-infrastructure -->

    docker-compose -f deploy/docker-compose/docker-compose.yml down

<!-- deploy-doc-end -->
