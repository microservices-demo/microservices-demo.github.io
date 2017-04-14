---
layout: quickstart
---
## Quick start

  The easiest and fastest way to get started with the Sock Shop application is by using Docker Compose.  If you don't have Docker and Compose installed, 
  please visit the [the Docker website](https://www.docker.com) for instructions on how to install them.

### Clone the application repository

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

### Start the application via Docker Compose

```
docker-compose -f deploy/docker-compose/docker-compose.yml up -d
```

Once the command exits the Sock Shop application should be up and running.

### Open the Sock Shop web page

Using your browser, visit http://localhost/ to see the Sock Shop webpage. 

### Cleaning up

```
docker-compose -f deploy/docker-compose/docker-compose.yml down
```