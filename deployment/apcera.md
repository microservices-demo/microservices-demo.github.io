---
layout: default
---

## Sock Shop on Apcera

These instructions will help you deploy and run the Sock Shop application on the [Apcera Platform](https://www.apcera.com/platform), an enterprise-grade container management platform for cloud-native and legacy applications.  Apcera is secure by default, only permitting things explicitly authorized by policy, and supports multi-cloud deployments.

Apcera has tested Sock Shop on the Apcera Community Edition running single-cloud clusters in Amazon AWS, Google Cloud Platform, Microsoft Azure, and VMware.  We have also tested Sock Shop on the Apcera Enterprise Edition running a multi-cloud cluster that spanned across AWS, GCP, and VMware.

### Packaging

The Sock Shop application is packaged and configured for Apcera using a [Multi-Resource Manifest file](https://docs.apcera.com/jobs/multi-resource-manifests/) called sockshop-docker.json which is similar to a Docker Compose file. Scripts are provided to make it easy to deploy all the services and a network from the manifest, to start and stop the services, and to delete everything that was deployed.


### Pre-requisites

- Set up your preferred private or public cloud environment, preferably AWS, Google, Azure, or VMware.
- Install [Apcera Community Edition (CE)](https://docs.apcera.com/setup/apcera-setup/) in your cloud or use the Apcera Enterprise Edition (EE) if you own it.
- Download the Apcera command line tool [APC](https://docs.apcera.com/quickstart/installing-apc/) from the Apcera [Web Console](https://docs.apcera.com/quickstart/using_console/) and install it.

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo/deploy/apcera
```
- *(Optional)* If you are not an admin user in your Apcera cluster, you might need an Apcera administrator to import a [policy](https://docs.apcera.com/policy/introduction/) file to give you permission to create the Sock Shop services and network in your sandbox.

```
apc policy import sockShop.pol
```

### Networking and Security

In this demo scenario, we create a single [virtual network](https://docs.apcera.com/jobs/virtual-networks/) to which all the services except *zipkin* and *user-sim* are added. Services inside the virtual network can all talk to each other. Apcera [job links](https://docs.apcera.com/jobs/job-links/) are used to let the *user-sim* load testing service send requests to the *front-end* service and to let the main Sock Shop services send traces to the *zipkin* service. Using job links in this fashion simulates how real, cloud-based load testing and APM solutions can be integrated into applications running on Apcera without sacrificing security.

### Deployment

All of the Sock Shop services and the network are deployed to Apcera with a single script. However, you first need to target your cluster and login to it with APC. After that, just run the deploySockShop.sh script.

<!-- deploy-doc require-env APCERA_CLUSTER APCERA_USER APCERA_PASSWORD -->
<!-- deploy-doc-hidden pre-install
apc target $APCERA_CLUSTER
printf "$APCERA_USER\n$APCERA_PASSWORD\n" | apc login --basic
-->
```
apc target <your_cluster>
apc login
```
<!-- deploy-doc-start create-infrastructure -->

    ./deploySockShop.sh

<!-- deploy-doc-end -->

After determining your targeted cluster and default namespace, this script does the following:

- It sets your current namespace to \<your_default_namespace\>/sockshop.
- It runs the "apc manifest deploy" command against the sockshop-docker.json manifest to create the services and the sockshop-network virtual network.
- It creates [job affinity tags](https://docs.apcera.com/jobs/job-affinity/) to make sure that each service that uses a database is deployed to the same Apcera instance manager as the database.
- It then runs the startSockShop.sh script to start all of the Sock Shop services.


Altogether, the script should take under two minutes to run.

### Using

- You can access the Sock Shop front-end service in a browser with the URL:
  - http://front-end.\<your_cluster\>
- Note that the *edge-router* service is not used since Apcera provides its own router.
- You can view logs for the services in the Apcera Web Console or by using the "apc app logs" command.

### Testing

A load testing service, *user-sim*, is provided in the sockshop-docker.json manifest file. It will run when the manifest is deployed after a delay of 60 seconds. This is a load test provided to simulate user traffic to the application. You can view the results of the test in the *user-sim* log.

### Tracing
[Zipkin](http://zipkin.io/) has been written into some of the services. While the system is up you can view the traces at http://zipkin.\<your_cluster\>. Currently *orders* provides the most comprehensive traces.

### Starting and Stopping

You can use the startSockShop.sh and stopSockShop.sh scripts to start and stop all the services.

### Cleaning up

Run the deleteSockShop.sh script to delete the Sock Shop services and network.


<!-- deploy-doc-start destroy-infrastructure -->

    ./deleteSockShop.sh

<!-- deploy-doc-end -->
