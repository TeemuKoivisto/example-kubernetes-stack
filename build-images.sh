#!/bin/bash -xe

cd ./my-react-bootstrap
REACT_APP_API_URL=http://localhost:9600 ./install.sh
./build.sh

cd ../my-node-bootstrap
./install.sh
./build.sh
