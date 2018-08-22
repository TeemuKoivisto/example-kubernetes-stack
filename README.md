# Example Kubernetes Stack

Stack for a basic CRUD-app with React, Node, TypeScript and Postgres using Kubernetes and Docker.

Utilizes my bootstrap projects as a basis:
* https://github.com/TeemuKoivisto/my-node-bootstrap
* https://github.com/TeemuKoivisto/my-react-bootstrap

## Prerequisites

You should have Docker, Kubernetes and kubectl installed locally. Also for developing the backend and frontend apps you should install Node.js.

## How to install

1) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`

## Creating the stack with Docker Compose

Docker Compose is a quite high-level way of deploying stacks made of Docker Images. It's best used for development environments only.

To create the stack first you have to build the images with `./build-images.sh`

Then launch the cluster with either `docker-compose up` or `docker-compose -d up` to run it as a daemon.

The app will be running at http://localhost:9443 and http://localhost:9080 (which should redirect to 9443) reverse proxying the requests to the Node appserver and Nginx webserver. Also the API is open at http://localhost:9600 for testing purposes.

To rebuild the local `my-reverse-proxy` image run `docker-compose build`.