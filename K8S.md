# How to run the local Kubernetes stack

There is also a [misc file](./K8S-MISC.md) for general blabbering about some issues I've had with running k8s locally.

## Prerequisites

You should have Docker, Kubernetes and kubectl installed locally. Also for developing the backend and frontend apps you should install Node.js.

## How to install with minikube and kubectl

1) Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and Docker if you don't already have it. I recommend using package-manager like Chocolatey. Minikube should install with VirtualBox as default driver which I recommend. When starting minikube you might want to increase its memory limit since it's default 1GB *is* too little for Helm charts (eg. Hadoop): `minikube --memory 4096 --cpus 2 start`. NOTE: this does not mean k8s will use 4 GBs of memory, just that it's able to.

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
* `kubectl delete deployment <name eg. my-react-bootstrap-deployment>` deletes specified resources.
* `kubectl delete deployment,svc -l app=my-node-bootstrap` will delete resources using a label selector.
* `kubectl get events` show recent events of the cluster.
* `kubectl logs <pod name>` shows logs of the specified pod.
* `kubectl set image deployment/my-react-bootstrap-deployment my-react-bootstrap-image=teemukoivisto/my-react-bootstrap:0.4.0` update the image of a deployment.
* `kubectl describe deployments` or `kubectl describe deployments my-react-bootstrap-deployment` to show detailed information of a resource(s).

* `kubectl apply -f kubernetes-templates` will create and update services based on the templates defined inside specified folder.
* `kubectl create secret generic my-pg-password --from-literal=password=asdfasdf` will create a secret variable available in your cluster. Run `kubectl get secrets` to see them listed.

## General

The app will be running at https://localhost:9443 and http://localhost:9080 (which should redirect to 9443) reverse proxying the requests to the Node appserver and Nginx webserver. Also the API is open at http://localhost:9600 for testing purposes.

There is however some issues with configuration so that http://localhost:9443 or https://localhost:9080 generate errors.
