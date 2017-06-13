---
layout: default
---

## Sock Shop on Applatix

Following instructions will help you deploy and run the Sock Shop application on Applatix. 
Applatix makes it simple and consumable for enterprises to build, test and deploy containerized apps in public cloud at scale whether it is a legacy app or micro services based app. 
Applatix clusters leverage Docker containers and Kubernetes as foundation and are deployed in customers cloud account- AWS or Google Compute Platform. Multiple Applatix clusters across multi-cloud can be centrally managed from Applatix portal.  
You can review how to deploy sock shop in this [demo movie](https://vimeo.com/220878494).

### Pre Requisites


1. [AWS Account](https://console.aws.amazon.com)
2. Sign up for [Applatix](https://pages.applatix.com/acton/media/25513/contact-us-for-a-free-trial-of-applatix)
3. Deploy one or more Applatix Kubernetes clusters in your AWS account

### Deployment

Applatix is driven by YAML DSL. YAML deployment specs of all the Sock Shop microservices are under **deploy/applatix** folder1. Fork the [https://github.com/microservices-demo/microservices-demo]() repo and move the **deploy/applatix** folder to **.applatix** folder under root
2. Once Applatix cluster is installed, integrate it with the github repo and under **Catalog** menu item you will see a **sock shop** app 
3. In Applatix, for the stateful microservices create EBS volumes with names **sock-shop-order-db**, **sock-shop-user-db**, **sock-shop-cart-db**, **sock-shop-cart**,  **sock-shop-shipping**,  **sock-shop-order**
4. Deploy sock shop from Applatix **Catalog**
5. It will take 1-2 minutes to deploy and you can see all the services in the web console


### Using

* You can access the Sock Shop front-end service in a browser * You can view logs for the services in the Applatix Web Console 

### Tracing

[Zipkin](http://zipkin.io/) has been written into some of the services. While the services are running you can view the traces.

### Starting, Stopping, Terminating

You can start, stop, terminate sock shop from Applatix web console.

### Uninstalling Applatix

You can uninstall Applatix cluster from applatix saas portal in one button click or you can manually delete it in your AWS account.

