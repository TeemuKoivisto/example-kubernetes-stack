# Example Kubernetes Stack

Stack for a basic CRUD-app with React, Node, TypeScript and Postgres using Kubernetes and Docker.

Utilizes my bootstrap projects as a basis:
* https://github.com/TeemuKoivisto/my-node-bootstrap
* https://github.com/TeemuKoivisto/my-react-bootstrap

## Prerequisites

You should have Docker, Kubernetes and kubectl installed locally. Also for developing the backend and frontend apps you should install Node.js.

## How to install with minikube and kubectl

1) Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and Docker if you don't already have it. I recommend using package-manager like Chocolatey. Minikube should install with VirtualBox as default driver which I recommend. When starting minikube you might want to increase its memory limit since it's default 1GB might be too little for Helm charts (eg. Hadoop): `minikube --memory 4096 --cpus 2 start`. NOTE: this does not mean k8s will use 4 GBs of memory, just that it's able to.

Here's a guide to these weird things: https://kubernetes.io/docs/tutorials/hello-minikube/.
`kubectl` is a commandline tool for communicating with your Kubernetes Master Node:
> `kubectl` is a command line interface for running commands against Kubernetes clusters.

Minikube is a tool that
> runs a single-node Kubernetes cluster inside a VM on your laptop

It comes with Docker Engine pre-installed. That Docker Engine is however different from your own local version which is why you have to do some extra work when building images.

2) Install [helm](https://docs.helm.sh/using_helm/). Then run `helm init`.
3) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`.
4) Start your local Kubernetes cluster: `minikube start`
5) Load the helper functions with `. functions.sh`. You can use them as eg. `rm-images my-node` or `rm-containers teemu`.
6) Build the images to minikube's Docker registry, install Nginx-controller Helm chart and create TLS-cert with: `k8s-build`
7) Install the k8s stack from the templates and generate TLS-secrets: `k8s-install`
8) And that's it! Run `k8s-url` to get the URL to the local ingress that's equivalent to the reverse-proxy in the Docker Compose stack.

## Using kubectl and minikube

It's advisable to read this https://kubernetes.io/docs/tutorials/hello-minikube/.

* `kubectl get pods/svc/deployments/etc.` shows the requested resources.
* `kubectl delete deployment,svc <name eg. my-react-bootstrap-deployment>` deletes specified resources.
* `kubectl delete svc -l app=my-node-bootstrap` will delete resources using a label selector.
* `kubectl get events` show recent events of the cluster.
* `kubectl logs <pod name>` shows logs of the specified log.
* `kubectl set image deployment/my-react-bootstrap-deployment my-react-bootstrap-image=teemukoivisto/my-react-bootstrap:0.4.0` update the image of a deployment.
* `kubectl describe deployments` or `kubectl describe deployments my-react-bootstrap-deployment` to show detailed information of a resource(s).

* `kubectl apply -f kubernetes-templates` will create and update services based on the templates defined inside specified folder.
* `kubectl create secret generic my-pg-password --from-literal=password=asdfasdf` will create a secret variable available in your cluster. Run `kubectl get secrets` to see them listed.

## How to install with Docker Compose

1) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`.
2) Follow the directions in `my-reverse-proxy` to create your own local SSL-certificate.
3) Load the helper functions with `. functions.sh`. You can use them as eg. `rm-images my-node` or `rm-containers teemu`.
4) Build the bootstrap images with `./build-images.sh`. Note that if you make changes to images you have to rebuild them from their respective folders using `./build.sh`. It uses the latest tag as its tag orphaning any images that were previously using it. Also the builder images remaining in the Docker's image registry as quite large `<none>` images that however speedup your build times and don't actually take any space at all (they reuse the layers from the Node/Nginx base-images making them far less than 1.0GB or something similar). You can remove them when you like with `rm-images none`.
5) Build the stack with `docker-compose build` (rebuild any changes to `my-reverse-proxy` with the same command).
6) Start the stack with `docker-compose up`.
7) Seed the database: `./seed-db.sh`. It uses the `add_test_data.sql` file from the `my-node-bootstrap`.
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

You can deploy your images to Docker Hub using:
```
docker login
docker build -t teemukoivisto/my-react-bootstrap:0.3.1 .
docker push teemukoivisto/my-react-bootstrap:0.3.1
```

## General

The app will be running at https://localhost:9443 and http://localhost:9080 (which should redirect to 9443) reverse proxying the requests to the Node appserver and Nginx webserver. Also the API is open at http://localhost:9600 for testing purposes.

There is however some issues with configuration so that http://localhost:9443 or https://localhost:9080 generate errors.

## Helpful extensions for VSCode

If you're using VSCode which I highly recommend you can install various of extensions to make developing much easier. Here's some of my favourites:

* Docker
* VS Live Share
* nginx.conf hint
* Code Spell Checker

For the TypeScript projects:

* vscode-styled-components
* TSLint
* Import Cost

Also I'm fan of auto-save, put this to your User Settings to enable it:
```
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 100,
```
