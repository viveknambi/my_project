# 3Tier under Toptal devops

This is the NodeJs 3Tier application under the devops practices for Toptal.

3Tier taken from [namikp/node-3tier-app](https://git.toptal.com/namikp/node-3tier-app). Modifications made solely to make it properly deployable - no actual app
code was modified.

# Requirements

You must install the following on your host machine:

* [Docker](https://www.docker.com/get-started)
* [Docker-Compose](https://docs.docker.com/compose/install/)
  * This comes bundled with Docker on Windows.
* [Terraform](https://www.terraform.io/downloads.html)
    * Manages IaaS resources, such as AWS servers
    * Make sure `terraform` is in your PATH.

Everything else runs within the Docker containers setup by the
[docker-compose.yml](docker-compose.yaml) file.

# Development

## One-time actions

* If you're on Windows or Mac, you will need to know the IP of the machine your
Docker containers are running on. Run `docker-machine ip` and remember that
address. It will usually be something like `192.168.99.100`. The instructions
will refer to `localhost` - you should read that as the docker-machine IP.

## Every-time actions

* `docker-compose up --build`
  * This can take a while, especially the first time. Go get some coffee.
  * All the logs will appear in this window.

Now, develop as you would any other NodeJS application. Every time you want to
see your code edits, `Control-C` in the window you ran `docker-compose`, then
restart the command.

## Accessing the services

* Go to `http://localhost:3000/` to access the web service.
* Go to `http://localhost:3001/` to access the api service.

# Deployment

All commands are described assuming you are in a Bash shell on your host
machine in the root directory of this repository.

There are a number of one-time actions that must take place before the CI/CD
pipeline can run code updates.

## One-time actions

### Required AWS privileges

Ensure you have set your AWS credentials correctly for an account with
(at least) the following authorizations:
  * CloudWatchFullAccess
  * DynamoDBFullAccess
  * ECSFullAccess
  * IAMFullAccess
  * S3FullAccess
  * RDSFullAccess
  * VPCFullAccess

### Setup Terraform minimums

In order for Terraform to be safely run in a non-single-user environment, the
tfstate files must be stored in a central place and a locking mechanism must be
enabled. For this project, we will the [S3 backend](https://www.terraform.io/docs/backends/types/s3.html).

Do the following work:

* In `devops/infrastructure/terraform/devops/main.tf`, comment out the section
marked.
* `(cd devops/infrastructure/terraform/devops; terraform init)`
* `(cd devops/infrastructure/terraform/devops; terraform apply -var-file prod.tfvars -auto-approve)`
* In `devops/infrastructure/terraform/devops/main.tf`, uncomment the section.
* `(cd devops/infrastructure/terraform/devops; terraform init)`
  * You will be asked to transfer the state. Say yes.
* `(cd devops/infrastructure/terraform/devops; terraform apply -var-file prod.tfvars -auto-approve)`
  * This should result in "0 added, 0 changed, 0 destroyed"

### Build the permanent infrastructure

* `(cd devops/infrastructure/terraform/3tier; terraform init)`
* The first time, comment out the cluster definitions. There is a comment in each cluster defition TF file for what and why.
* `(cd devops/infrastructure/terraform/3tier; terraform apply -var-file prod.tfvars -auto-approve)`
  * This will take a while the first time it is run.
* `./devops/bin/tag_push.sh`
  * This assumes you have run `docker-compose up -build` at least once.
* Uncomment what you commented.
* `(cd devops/infrastructure/terraform/3tier; terraform apply -var-file prod.tfvars -auto-approve)`
  * Even though it will return quickly, the tasks will take a while to start.

### Deploying a new version of the app

You will need to have retrieved your AccountID. Easiest way to do this is to
call `aws sts get-caller-identity` and save `"Account"`.

* `./devops/bin/ecr_login.sh`
* `./devops/bin/tag_push.sh`

# Possible Improvements

## Development Environment

### Live reloading

The ideal development environment is edit, then hit reload. Currently, the
developer also needs to restart `docker-compose` (a "compile" step). This
introduces friction, reducing effectiveness.

Introducing [nodemon](https://nodemon.io/) could be one option, but would
require some restructuring of the application. This must be done with the
collaboration of the developers.

## Deployment

### Multiple Terraforms

All of the Terraform for this project are in one bunch. This is fragile,
both as the number of elements in the project grows and as the number of
projects overall grows. The appropriate solution is to put things that should
be destroyed together in one bunch and capture appropriate outputs to a JSON
file stored in an S3 bucket. Then, to use these outputs as inputs to another
chunk of Terraform, wrapper scripting needs to be created around Terraform to
read the appropriate JSON file(s) from the S3 bucket and inject the required
variables. For example, `vpc_id`, `subnet_id`, and similar values should be
created in one Terraform group, then reused in other groups. Possibly in other
project repositories.
