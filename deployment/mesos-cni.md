---
layout: default
deployDoc: true
---

## Deploying Sock Shop on Mesos using CNI

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

This guide describes how to deploy Sock Shop to a Mesos cluster that has CNI and Weave Net installed. Deployment is done using the `mesos-execute` commands.

*For testing only* Because CNI support is so new, it is not supported in Marathon and some features are missing from Weave. The containers are not orchestrated, so if they crash, they will not be restarted.

### Caveates

- Tested with Mesos 1.0.0
- These scripts start containers using mesos-execute. Not marathon (due to lack of marathon support). Hence, they are not orchestrated. If they crash, they will not be restarted.
- Sometimes Docker hub can respond with 500's. It might take few tries to get it running.
- Mesos only supports CNI from version 1.0.0+
- Mesos only supports CNI on the Mesos containerizer
- Weave DNS does not work with Weave CNI
- This was developed on AWS. May not work on other services.

Please read this blog post about the new [mesos unified containerizer](http://winderresearch.com/2016/07/02/Overview-of-Mesos-New-Unified-Containerizer/) for more information.

### Usage

```
mesos-cni.sh [OPTION]... [COMMAND]

Starts the weavedemo project on Apache Mesos using CNI. It expects that you have populated the Masters and Agents in this script. See https://github.com/philwinder/mesos-terraform for help with installing Mesos on AWS.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

Commands:
install           Install all required services on the Mesos hosts. Must install before starting.
uninstall         Removes all installed services
start             Starts the demo application services. Must already be installed.
stop              Stops the demo application services

Options:
--force           Skip all user interaction.  Implied 'Yes' to all actions.
-c, --cpu         Individual task CPUs
-m, --mem         Individual task Mem
-t, --tag         Sets the tag of the docker images
-q, --quiet       Quiet (no output)
-l, --log         Print log to file
-s, --strict      Exit script with null variables.  i.e 'set -o nounset'
-v, --verbose     Output more information. (Items echoed to 'verbose')
-d, --debug       Runs script in BASH debug mode (set -x)
-h, --help        Display this help and exit
--version     Output version information and exit
```

### Installing the prerequisites

Provisioning a Mesos cluster requires the following prerequisites

* `git`
* `curl`
* `jq` - [https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)
* `terraform`
* `Mesos Terraform on AWS` - [https://github.com/philwinder/mesos-terraform](https://github.com/philwinder/mesos-terraform)

<!-- deploy-doc-start pre-install -->

    curl -sSL https://get.docker.com/ | sh

    apt-get update && apt-get install -yq jq python-pip curl unzip build-essential python-dev
    pip install awscli

    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.7.11/terraform_0.7.11_linux_amd64.zip
    unzip /tmp/terraform.zip -d /usr/bin

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden pre-install

    mkdir -p ~/.ssh
    aws ec2 describe-key-pairs -\-key-name ci-mesos-cni &>/dev/null
    if [ $? -eq 0 ]; then aws ec2 delete-key-pair -\-key-name ci-mesos-cni; fi

-->

### Create the infrastructure

Create a key pair on AWS and run Mesos Terraform to create the Mesos cluster.

<!-- deploy-doc-start create-infrastructure -->

    git clone https://github.com/philwinder/mesos-terraform /tmp/mesos-terraform
    cd /tmp/mesos-terraform

    aws ec2 create-key-pair --key-name ci-mesos-cni --query 'KeyMaterial' --output text > ~/.ssh/ci-mesos-cni-key.pem
    chmod 600 ~/.ssh/ci-mesos-cni-key.pem

    export TF_VAR_aws_region='eu-central-1'
    export TF_VAR_aws_availability_zone='eu-central-1a'
    export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_private_key_file=$HOME/.ssh/ci-mesos-cni-key.pem
    export TF_VAR_aws_key_name=ci-mesos-cni

    terraform apply

<!-- deploy-doc-end -->

### Deploy Sock Shop

Now deploy Sock Shop

<!-- deploy-doc-start create-infrastructure -->

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')
    cd deploy/mesos-cni
    ./mesos-cni.sh install
    ./mesos-cni.sh start

<!-- deploy-doc-end -->

### Running the load test

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

<!-- deploy-doc-start run-tests -->

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')
    docker run --rm weaveworksdemos/load-test -d 300 -h $SLAVE0 -c 2 -r 100

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden run-tests

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')

    ssh -i $KEY ubuntu@$MASTER 'sudo mesos-execute -\-networks=weave -\-shell -\-resources=cpus:0.2\;mem:1024 -\-name=healthcheck -\-command="cd /; ./healthcheck.rb -s orders.mesos-executeinstance.weave.local,user.mesos-executeinstance.weave.local,payment.mesos-executeinstance.weave.local,carts.mesos-executeinstance.weave.local,catalogue.mesos-executeinstance.weave.local,shipping.mesos-executeinstance.weave.local -d 60 -r 5" -\-docker_image=weaveworksdemos/healthcheck:snapshot -\-master=localhost:5050' > /tmp/healthcheck.log

    ssh -i $KEY ubuntu@$MASTER ". ~/.profile; mesos tail -n 100 -i healthcheck stdout"

    RET=$(cat /tmp/healthcheck.log | perl -n -e'/status ([0-9]+)/ && print $1')
    if [ $RET -ne 0 ]; then
        exit 1;
    fi

-->

### Cleaning up

Destroy the Mesos cluster and Sock Shop

<!-- deploy-doc-start destroy-infrastructure -->

    export TF_VAR_aws_region='eu-central-1'
    export TF_VAR_aws_availability_zone='eu-central-1a'
    export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_private_key_file=$HOME/.ssh/ci-mesos-cni-key.pem
    export TF_VAR_aws_key_name=ci-mesos-cni
    cd /tmp/mesos-terraform
    terraform destroy -force
    aws ec2 delete-key-pair --key-name ci-mesos-cni

<!-- deploy-doc-end -->
