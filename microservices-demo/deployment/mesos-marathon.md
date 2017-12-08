---
layout: default
deployDoc: true
---

## Deploying Sock Shop on Mesos using Marathon

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

These scripts will install the microservices demo on Apache Mesos using Marathon.

### Caveats
- This was developed on AWS. May not work on other services.

### Usage

```
./mesos-marathon.sh [OPTION]... [COMMAND]
Starts the weavedemo microservices demo on Mesos using Marathon.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

Commands:
install           Install all required services on the Mesos hosts. Must install before starting.
uninstall         Removes all installed services
start             Starts the demo application services. Must already be installed.
stop              Stops the demo application services

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

### Installing the prerequisites
* `git`
* `terraform`
* `Mesos Terraform on AWS` - [https://github.com/philwinder/mesos-terraform](https://github.com/philwinder/mesos-terraform)
* `curl`

<!-- deploy-doc-start pre-install -->

    curl -sSL https://get.docker.com/ | sh

    apt-get install -yq jq python-pip curl unzip build-essential python-dev
    pip install awscli

    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.7.11/terraform_0.7.11_linux_amd64.zip
    unzip /tmp/terraform.zip -d /usr/bin

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden pre-install

    mkdir -p ~/.ssh
    aws ec2 describe-key-pairs -\-key-name ci-mesos-marathon &>/dev/null
    if [ $? -eq 0 ]; then aws ec2 delete-key-pair -\-key-name ci-mesos-marathon; fi

-->


### Creating the infrastructure

Create a key pair on AWS and run Mesos Terraform to create the Mesos cluster.

<!-- deploy-doc-start create-infrastructure -->

    git clone https://github.com/philwinder/mesos-terraform /tmp/mesos-terraform
    cd /tmp/mesos-terraform

    aws ec2 create-key-pair --key-name ci-mesos-marathon --query 'KeyMaterial' --output text > ~/.ssh/ci-mesos-marathon-key.pem
    chmod 600 ~/.ssh/ci-mesos-marathon-key.pem

    export TF_VAR_aws_region='eu-central-1'
    export TF_VAR_aws_availability_zone='eu-central-1a'
    export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_private_key_file=$HOME/.ssh/ci-mesos-marathon-key.pem
    export TF_VAR_aws_key_name=ci-mesos-marathon

    terraform apply

<!-- deploy-doc-end -->

### Deploying the Sock Shop

<!-- deploy-doc-start create-infrastructure -->

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')
    cd deploy/mesos-marathon
    ./mesos-marathon.sh install
    ./mesos-marathon.sh start

<!-- deploy-doc-end -->

### Running load tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

<!-- deploy-doc-start run-tests -->

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')
    docker run --rm weaveworksdemos/load-test -d 500 -h $SLAVE0 -c 2 -r 100

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden run-tests

    eval $(terraform output -state=/tmp/mesos-terraform/terraform.tfstate -json | jq -r '.[].value')
    ssh -i $KEY ubuntu@$SLAVE0 "eval \$(weave env); docker run -\-rm weaveworksdemos/healthcheck:snapshot -s orders,carts,payment,user,catalogue,shipping,queue-master -d 60 -r 5"

    if [ $? -ne 0 ]; then
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
    export TF_VAR_private_key_file=~/.ssh/ci-mesos-marathon-key.pem
    export TF_VAR_aws_key_name=ci-mesos-marathon
    cd /tmp/mesos-terraform
    terraform destroy -force
    aws ec2 delete-key-pair --key-name ci-mesos-marathon

<!-- deploy-doc-end -->
