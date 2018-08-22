#!/bin/bash -xe

OS=$1

if [ -z "$OS" ]; then
  echo "Missing first argument OS. It should be either macos or linux."
  exit 0
fi

if [ "$OS" = "macos" ]; then
  #sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localhost.crt
fi
