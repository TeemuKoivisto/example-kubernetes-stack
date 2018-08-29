#!/bin/bash -xe

ENV=$1

if [ -z "$ENV" ]; then
  echo "Missing first argument ENV. It should be either docker or k8s."
  exit 0
fi

if [ "$ENV" = "docker" ]; then
  RUNNING_DB_SHA="$(docker ps | grep my_postgres | awk '{print $1}')"

  if [ -z "$RUNNING_DB_SHA" ]; then
    echo "No running DB called my_postgres"
    exit 0
  fi

  DB_HOST=localhost
  DB_PORT=5600
  DB_USER=pg-user
  DB_PASSWORD=my-pg-password
  DB_NAME=my_postgres_db

  psql postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} < ./my-node-bootstrap/db/scripts/add_test_data.sql
fi

if [ "$ENV" = "k8s" ]; then
  RUNNING_DB_PORT="$(kubectl get svc my-postgres-svc -o yaml | grep nodePort | awk '{print $3}')"

  if [ -z "$RUNNING_DB_PORT" ]; then
    echo "No running service called my-postgres-svc"
    exit 0
  fi

  DB_HOST="$(minikube ip)"
  DB_PORT="${RUNNING_DB_PORT}"
  DB_USER=pg-user
  DB_PASSWORD="$(kubectl get secret my-postgres-secret -o yaml | grep password | sed -n '1p' | awk '{print $2}' | base64 --decode)"
  DB_NAME=my_postgres_db

  psql postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} < ./my-node-bootstrap/db/scripts/add_test_data.sql
fi
