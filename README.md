# Example Kubernetes Stack

Stack for a basic CRUD-app with React, Node, TypeScript and Postgres using Kubernetes and Docker.

## Prerequisites

You should have Docker, Kubernetes and kubectl installed locally. Also for developing the backend and frontend apps you should install Node.js.

## How to install

1) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`

## Creating the stack with Docker Compose

Docker Compose is a quite high-level way of deploying stacks made of Docker Images. It's best used for development environments only.

To create the stack first you have to build the images with `./build-images.sh`

Then launch the cluster with either `docker-compose up` or `docker-compose -d up` to run it as a daemon.