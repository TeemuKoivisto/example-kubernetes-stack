# Example Kubernetes Stack

Stack for a basic CRUD-app with React, Node, TypeScript and Postgres using Kubernetes and Docker.

Utilizes my bootstrap projects as a basis:
* https://github.com/TeemuKoivisto/my-node-bootstrap
* https://github.com/TeemuKoivisto/my-react-bootstrap

## Prerequisites

You should have Docker, Kubernetes and kubectl installed locally. Also for developing the backend and frontend apps you should install Node.js.

## How to install with Docker Compose

1) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`.
2) Follow the directions in `my-reverse-proxy` to create your own local SSL-certificate.
3) Load the helper functions with `. functions.sh`. You can use them as eg. `rm-images my-node` or `rm-containers teemu`.
4) Build the bootstrap images with `./build-images.sh`. Note that if you make changes to images you have to rebuild them from their respective folders using `./build.sh`. It uses the latest tag as its tag orphaning any images that were previously using it. Also the builder images remaining in the Docker's image registry as quite large `<none>` images that however speedup your build times and don't actually take any space at all (they reuse the layers from the Node/Nginx base-images making them far less than 1.0GB or something similar). You can remove them when you like with `rm-images none`.
5) Build the stack with `docker-compose build` (rebuild any changes to `my-reverse-proxy` with the same command).
6) Start the stack with `docker-compose up`.
7) Seed the database with the `add_test_data.sql` file from the `my-node-bootstrap`.
8) And that's it! The app should be available at https://localhost:9443.

## Using Docker Compose

Docker Compose is a quite high-level way of deploying stacks made of Docker Images. It's best used for development environments only.

Here's some useful commands with it:

* `docker-compose up` will launch the stack as a process that you can manually exit.
* `docker-compose -d up` will launch it as a daemon in a background.
* `docker-compose stop` will the stop the containers and `docker-compose start` restart them as daemon processes.
* `docker-compose up -d my_postgres_db` will launch only a one service.
* `docker-compose down` stops and removes all the containers of the stack.
* `docker-compose build` rebuilds the images specified as Dockerfiles in the `docker-compose.yml` (currently only my-reverse-proxy).

## General

The app will be running at https://localhost:9443 and http://localhost:9080 (which should redirect to 9443) reverse proxying the requests to the Node appserver and Nginx webserver. Also the API is open at http://localhost:9600 for testing purposes.

There is however some issues with configuration so that http://localhost:9443 or https://localhost:9080 generate errors.