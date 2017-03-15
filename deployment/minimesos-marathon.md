---
layout: default
deployDoc: true
---

## Deploying Sock Shop on Mesos using minimesos

[minimesos](https://minimesos.org) is an in memory mesos cluster. This script will deploy the demo application to mesos.

### Usage

```
minimesos-marathon.sh [OPTION]... [COMMAND]

Starts the weavedemo microservices application on minimesos.

Requirements: Docker, weave and minimesos must be installed.

Commands:
start             Starts weave, minimesos and the demo application
stop              Stops weave, minimesos and the demo application

Options:
--force           Skip all user interaction.  Implied 'Yes' to all actions.
-q, --quiet       Quiet (no output)
-l, --log         Print log to file
-s, --strict      Exit script with null variables.  i.e 'set -o nounset'
-v, --verbose     Output more information. (Items echoed to 'verbose')
-d, --debug       Runs script in BASH debug mode (set -x)
-h, --help        Display this help and exit
--version     Output version information and exit

```

### Prerequisites
- [`minimesos`](https://minimesos.org)
- `weave`
- `curl`

<!-- deploy-doc-hidden pre-install

    apt-get update
    apt-get install -yq sudo net-tools

-->

<!-- deploy-doc-start create-infrastructure -->

    sudo curl -sSL https://get.docker.com/ | sh

    sudo curl -sSL https://minimesos.org/install | sh
    sudo mv ~/.minimesos/bin/minimesos /usr/bin/

    sudo curl -L git.io/weave -o /usr/local/bin/weave
    sudo chmod a+x /usr/local/bin/weave

<!-- deploy-doc-end -->

<!-- deploy-doc-start create-infrastructure -->

    cd deploy/minimesos-marathon
    ./minimesos-marathon.sh start

<!-- deploy-doc-end -->

### Running the load test

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

<!-- deploy-doc-start run-tests -->

    cd deploy/minimesos-marathon
    docker run --rm --net=host weaveworksdemos/load-test -d 300 -h localhost -c 2 -r 100

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden run-tests

    docker run -\-rm -v=/var/run/weave/weave.sock:/var/run/weave/weave.sock docker docker -H=unix:///var/run/weave/weave.sock run -\-rm -\-name=healthcheck weaveworksdemos/healthcheck:snapshot -s catalogue,user,carts,orders,shipping,queue-master,payment -d 60 -r 5

    if [ $? -ne 0 ]; then
        exit 1;
    fi

-->

### Cleaning up

<!-- deploy-doc-start destroy-infrastructure -->

    cd deploy/minimesos-marathon
    ./minimesos-marathon.sh stop

<!-- deploy-doc-end -->
