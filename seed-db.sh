#!/bin/bash -xe

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
