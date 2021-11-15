
# Databases in Docker

Provides a way to containerize various databases by the use of docker-compose.yaml (and alternatives) files.

## Features

- Allows for databases to be put into docker containers
- Uses Docker Stacks to run the containers in Kubernetes (optional)
- Allows for multiple database types (SQL Server, Postgres etc) on multiple environments (dev, test, qa etc)

## Installation 

Install Docker Desktop

https://www.docker.com/products/docker-desktop


## Tech Stack

Docker, Kubernetes, Minikube

## Run Locally

### Simple docker deployment using docker-compose.yaml file

This runs the databases in containers as part of a stack, but not in a kubernetes cluster.

```
  docker-compose up
```

### Kubernetes deployment in a local cluster

Choose the file that you would need. 

```
  docker stack deploy -c db_dev.yaml
```

### Kubernetes deployment using Kompose

Choose the file that you would need. 

```
  docker stack deploy -c db_dev.yaml
```

## License

[MIT](https://choosealicense.com/licenses/mit/)


## Acknowledgements

 - [Readme Templating Tool](https://readme.so)

## TODO

- Use ENV variables to setup yaml file and deploy to the environment using a single yaml file.
