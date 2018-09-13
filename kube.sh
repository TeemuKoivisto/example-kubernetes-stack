#!/bin/bash -xe

k8s-build() {
  eval $(minikube docker-env)

  ./build-images.sh

  helm install stable/nginx-ingress --set rbac.create=false --set rbac.createRole=false --set rbac.createClusterRole=false

  ./my-reverse-proxy/generate-key.sh "local"
}

k8s-install() {
  kubectl apply -f ./k8s-templates/my-postgres
  kubectl apply -f ./k8s-templates/my-react-bootstrap
  kubectl apply -f ./k8s-templates/my-node-bootstrap
  kubectl apply -f ./k8s-templates/my-ingress

  sleep 5

  kubectl create -f ./k8s-templates/my-jobs/postgres-migration-job.yml

  sleep 5

  kubectl create -f ./k8s-templates/my-jobs/postgres-seed-job.yml

  kubectl create secret tls my-tls-certificate --key ./my-reverse-proxy/localhost.key --cert ./my-reverse-proxy/localhost.crt 
  kubectl create secret generic my-tls-dhparam --from-file=./my-reverse-proxy/dhparam4096.pem

}

k8s-delete() {
  kubectl delete -f ./k8s-templates/my-postgres
  kubectl delete -f ./k8s-templates/my-react-bootstrap
  kubectl delete -f ./k8s-templates/my-node-bootstrap
  kubectl delete -f ./k8s-templates/my-ingress
  kubectl delete job -l job=my-postgres-migration
  kubectl delete job -l job=my-postgres-seed
  kubectl delete secret my-tls-certificate
}
