---
layout: default
deployDoc: true
---

## Sock Shop on Kubernetes + Weave 

This demo demonstrates running the Sock Shop on a Kubernetes cluster using 
Weave Net and Weave Scope.

### Pre-requisites
* *Optional* [Terraform](https://www.terraform.io/downloads.html)
* *Optional* [AWS Account](https://aws.amazon.com/)
* *Optional* [awscli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->
<!-- deploy-doc-start pre-install -->

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq jq python-pip curl unzip build-essential python-dev
    pip install awscli
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.7.11/terraform_0.7.11_linux_amd64.zip
    unzip /tmp/terraform.zip -d /usr/bin

<!-- deploy-doc-end -->

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```
<!-- deploy-doc-hidden pre-install

    mkdir -p ~/.ssh/
    aws ec2 describe-key-pairs -\-key-name deploy-docs-k8s &>/dev/null
    if [ $? -eq 0 ]; then aws ec2 delete-key-pair -\-key-name deploy-docs-k8s; fi

-->

### Setup Kubernetes

Begin by setting the appropriate AWS environment variables.

```
export AWS_ACCESS_KEY_ID=[YOURACCESSKEYID]
export AWS_SECRET_ACCESS_KEY=[YOURSECRETACCESSKEY]
export AWS_DEFAULT_REGION=[YOURDEFAULTREGION]
export TF_VAR_aws_region=$AWS_DEFAULT_REGION
```

Next we'll create a private key for use during this demo.

<!-- deploy-doc-start create-infrastructure -->

    aws ec2 create-key-pair --key-name deploy-docs-k8s --query 'KeyMaterial' --output text > ~/.ssh/deploy-docs-k8s.pem
    chmod 600 ~/.ssh/deploy-docs-k8s.pem

<!-- deploy-doc-end -->

Finally run terraform.

<!-- deploy-doc-start create-infrastructure -->

    terraform apply deploy/kubernetes/terraform/

<!-- deploy-doc-end -->

Our master node makes use of some of the files in this repo so lets securely copy those over.

<!-- deploy-doc-start create-infrastructure -->

    master_ip=$(terraform output -json | jq -r '.master_address.value')
    scp -i ~/.ssh/deploy-docs-k8s.pem -o StrictHostKeyChecking=no -rp deploy/kubernetes/manifests ubuntu@$master_ip:/tmp/

<!-- deploy-doc-end -->

### <a name="weavenet"></a>Setup Weave Net
* Run the following commands to setup Kubernetes and Weave Net on the master instance

<!-- deploy-doc-start create-infrastructure -->

    master_ip=$(terraform output -json | jq -r '.master_address.value')
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip sudo kubeadm init > k8s-init.log
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip "sudo cp /etc/kubernetes/admin.conf /home/ubuntu/"
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip "sudo chown \$(id -u):\$(id -g) \$HOME/admin.conf"
    grep -e --token k8s-init.log > join.cmd
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip KUBECONFIG=\$HOME/admin.conf kubectl apply -f https://git.io/weave-kube-1.6

<!-- deploy-doc-end -->

### Time for the nodes to join the master
* Run the following commands to SSH into each node\_addresses and run the ```kubeadm join --token <token> <master-ip>``` command from before.

<!-- deploy-doc-start create-infrastructure -->

    node_addresses=$(terraform output -json | jq -r '.node_addresses.value|@sh' | sed -e "s/'//g" )
    for node in $node_addresses; do
        ssh -i ~/.ssh/deploy-docs-k8s.pem -o StrictHostKeyChecking=no ubuntu@$node sudo `cat join.cmd`
    done

<!-- deploy-doc-end -->

### Setup Weave Scope
There are two options for running Weave Scope, either you can run the UI locally, or using the hosted provider at [cloud.weave.works](http://cloud.weave.works)

#### Locally
* SSH into the master node
* Start weave scope on the cluster

<!-- deploy-doc-start create-infrastructure -->

    master_ip=$(terraform output -json | jq -r '.master_address.value')
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip KUBECONFIG=\$HOME/admin.conf kubectl apply -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml'

<!-- deploy-doc-end -->

#### Hosted
* SSH into the master node
* Running the Scope UI on Weave Cloud using the ```<token>``` from [cloud.weave.works](http://cloud.weave.works)

```
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip kubectl apply -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml?service-token=<token>'
```

### *(Optional)* Setup Weave Flux
You may optionally choose to configure Weave Flux which allows automatic deployment of changes. Unfortunately it's beyond the scope of this document, but you can read more about it [here](http://www.weave.works/guides/cloud-guide-part-2-deploy-continuous-delivery/).

### *(Optional)* Setup Fluentd + ELK based logging
* Copy the logging manifests
* Start Fluentd, Elasticsearch and Kibana

```
    master_ip=$(terraform output -json | jq -r '.master_address.value')
    scp -i ~/.ssh/deploy-docs-k8s.pem -rp deploy/kubernetes/manifests-logging ubuntu@$master_ip:/tmp/
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip kubectl apply -f /tmp/manifests-logging/
```

### Deploy Sock Shop
* SSH into the master node
* Deploy the sock shop

<!-- deploy-doc-start create-infrastructure -->

    master_ip=$(terraform output -json | jq -r '.master_address.value')
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip KUBECONFIG=\$HOME/admin.conf kubectl apply -f /tmp/manifests/sock-shop-ns.yaml -f /tmp/manifests

<!-- deploy-doc-end -->

### Deploy Sock Shop with Opentracing (optional)
To deploy with opentracing run after deploying the sock-shop

```
    master_ip=$(terraform output -json | jq -r '.master_address.value')
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip KUBECONFIG=\$HOME/admin.conf kubectl apply -f /tmp/manifests-zipkin/zipkin-ns.yaml -f /tmp/manifests-zipkin
```

### Service autoscaling (optional)
If you want all stateless services to scale automatically based on the CPU utilization, you can deploy all the manifests in the "deploy/kubernetes/autoscaling" directory.
The autoscaling directory contains Kubernetes horizontal pod autoscalers for all the stateless services, and the Heapster monitoring application with it's depedencies.

```
    master_ip=$(terraform output -json | jq -r '.master_address.value')
    scp -i ~/.ssh/deploy-docs-k8s.pem -o StrictHostKeyChecking=no -rp deploy/kubernetes/autoscaling ubuntu@$master_ip:/tmp/
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip kubectl apply -f /tmp/autoscaling
```

If you cause enough load on the application you should see the various services scaling up in number.

### View the results
Run `terraform output` command to see the load balancer and node URLs

The sock shop is available at the sock_shop_address as displayed below. The scope app is accessible via the master and
any of the node urls on port 30001, while the same applies for Kibana if you deployed it, but using port 31601. It may take a few moments for the apps to get running.

```
Outputs:

master_address = ec2-52-213-213-161.eu-west-1.compute.amazonaws.com
node_addresses = [
    ec2-52-213-136-12.eu-west-1.compute.amazonaws.com,
    ec2-52-208-64-132.eu-west-1.compute.amazonaws.com,
    ec2-52-48-129-206.eu-west-1.compute.amazonaws.com
]
sock_shop_address = MD-k8s-elb-sock-shop-1211989270.eu-west-1.elb.amazonaws.com

```

### Run tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

```

    elb_url=$(terraform output -json | jq -r '.sock_shop_address.value')
    docker run --rm weaveworksdemos/load-test -d 300 -h $elb_url -c 2 -r 100

```

<!-- deploy-doc-hidden run-tests

    set -e

    elb_url=$(terraform output -json | jq -r '.sock_shop_address.value')
    docker run --rm weaveworksdemos/load-test -d 300 -h $elb_url -c 2 -r 100

    master_ip=$(terraform output -json | jq -r '.master_address.value')
    ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip "KUBECONFIG=\$HOME/admin.conf kubectl run -i -t -\-namespace=sock-shop healthcheck -\-restart=Never -\-image=weaveworksdemos/healthcheck:snapshot -- -s orders,carts,payment,user,catalogue,shipping,queue-master -d 60 -r 5"

    set +e

-->

### Opentracing

Zipkin is part of the deployment and has been written into some of the services.  While the system is up you can view the traces in
Zipkin at http://\<loadbalancer\>:9411.  Currently orders provide the most comprehensive traces.


### Uninstall App

Remove all deployments (will also remove pods)

```
ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip kubectl delete deployments --all
```

Remove all services, except kubernetes

```
ssh -i ~/.ssh/deploy-docs-k8s.pem ubuntu@$master_ip kubectl delete service $(kubectl get services | cut -d" " -f1 | grep -v NAME | grep -v kubernetes)
```

Destroying the entire infrastructure

<!-- deploy-doc-start destroy-infrastructure -->

    terraform destroy -force deploy/kubernetes/terraform/
    aws ec2 delete-key-pair -\-key-name deploy-docs-k8s
    rm -f ~/.ssh/deploy-docs-k8s.pem
    rm -f terraform.tfstate
    rm -f terraform.tfstate.backup
    rm -f k8s-init.log
    rm -f join.cmd

<!-- deploy-doc-end -->
