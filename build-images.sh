#!/bin/bash -xe

cd ./my-react-bootstrap
./build.sh

cd ../my-node-bootstrap
./build.sh

cd ../my-reverse-proxy
./build.sh
