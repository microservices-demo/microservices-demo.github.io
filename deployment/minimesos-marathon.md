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

Requirements: Docker-machine, weave and minimesos must be installed.

Tested on: docker-machine version 0.7.0, build a650a40. Weave 1.6.0. minimesos 0.9.0. Mesos 0.25.

Commands:
install           Creates a new docker-machine VM.
route             Create a route towards the docker-machine
uninstall         Removes docker-machine VM.
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
- *macOS only* `Docker-machine`
- [`minimesos`](https://minimesos.org)
- `weave`
- `curl`

<!-- deploy-doc-hidden pre-install

    apt-get update
    apt-get install -yq sudo

-->

<!-- deploy-doc-start create-infrastructure -->

    sudo curl -sSL https://get.docker.com/ | sh

    sudo curl -sSL https://minimesos.org/install | sh
    sudo mv ~/.minimesos/bin/minimesos /usr/bin/

    sudo curl -L git.io/weave -o /usr/local/bin/weave
    sudo chmod a+x /usr/local/bin/weave

<!-- deploy-doc-end -->

### Linux (Ubuntu 16.04)

<!-- deploy-doc-start create-infrastructure -->

    cd deploy/minimesos-marathon
    ./minimesos-marathon.sh start

<!-- deploy-doc-end -->

### macOS

This will add a route between local-\>VM-\>application/Mesos. Without this you won't be able to access Mesos from your local machine. You'd have to run another container to gain access.

```
./minimesos-marathon.sh install
./minimesos-marathon.sh route
./minimesos-marathon.sh start
```

### Running the load test

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

<!-- deploy-doc-start run-tests -->

    docker run --rm weaveworksdemos/load-test -d 300 -h localhost -c 2 -r 100

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden run-tests

    docker run -\-rm weaveworksdemos/healthcheck:snapshot -s orders,cart,payment,user,catalogue,shipping,queue-master -d 60 -r 5

-->

### Cleaning up

### Linux

<!-- deploy-doc-start destroy-infrastructure -->

    ./minimesos-marathon.sh stop

<!-- deploy-doc-end -->

### macOS

```
./minimesos-marathon.sh stop
./minimesos-marathon.sh uninstall
```
