#!/bin/bash -xe

rm-images() {
  local GREP_STRING=$1
  rm-containers "${GREP_STRING}"
  docker images | grep "${GREP_STRING}" | awk '{print $3}' | xargs docker rmi -f
}

rm-containers() {
  local GREP_STRING=$1
  OLD_CONTAINER_ID="$(docker ps -a | grep ${GREP_STRING} | awk '{print $1}')"
  docker stop "${OLD_CONTAINER_ID}" || true
  docker rm "${OLD_CONTAINER_ID}" || true
}

denv() {
  local ENV=$1

  if [ -z "$ENV" ]; then
    echo "Missing first argument ENV. It should be either k8s or local."
    exit 0
  fi

  if [ "$ENV" = "k8s" ]; then
    eval $(minikube docker-env)
  fi

  if [ "$ENV" = "local" ]; then
    eval $(minikube docker-env -u)
  fi
}

# Just a random function to remember how tunneling was done
tunnel() {
  local SSH_NAME=$1 # your login ssh-name, eg. teemu
  local TARGET_IP=$2
  local TUNNELED_ADDRESS=$3 # eg. 127.0.0.1:80
  ssh -L 9000:$TUNNELED_ADDRESS $SSH_NAME@$TARGET_IP 
}

k8s-build() {
  eval $(minikube docker-env)

  ./build-images.sh

  helm install --name my-nginx-ingress stable/nginx-ingress \
    --set rbac.create=false --set rbac.createRole=false --set rbac.createClusterRole=false

  cd ./my-reverse-proxy
  ./generate-key.sh "local"
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

k8s-url() {
  minikube service my-nginx-ingress-controller --url | awk 'NR==2{print $0}' | sed 's/http:\/\///' | awk '{print "https://"$0}'
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
