
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

