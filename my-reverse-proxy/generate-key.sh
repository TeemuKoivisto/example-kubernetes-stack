#!/bin/bash -xe

KEYTYPE=$1

if [ -z "$KEYTYPE" ]; then
  echo "Missing first argument KEYTYPE. It should be either local or dhparam."
  exit 0
fi

# https://letsencrypt.org/docs/certificates-for-localhost/

if [ "$KEYTYPE" = "local" ]; then
  openssl req -x509 -out localhost.crt -keyout localhost.key \
    -newkey rsa:2048 -nodes -sha256 \
    -subj '/CN=localhost' -extensions EXT -config <( \
    printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
fi

if [ "$KEYTYPE" = "dhparam" ]; then
  # This will take about 20 minutes
  openssl genpkey -genparam -algorithm DH -out dhparam4096.pem -pkeyopt dh_paramgen_prime_len:4096
fi
