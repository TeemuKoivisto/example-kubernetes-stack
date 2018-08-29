#!/bin/bash -xe

kubectl create -f ./kubernetes-templates/my-react-bootstrap/mrb-deployment.yml
kubectl create -f ./kubernetes-templates/my-react-bootstrap/mrb-service.yml

eval $(minikube docker-env)

eval $(minikube docker-env -u)