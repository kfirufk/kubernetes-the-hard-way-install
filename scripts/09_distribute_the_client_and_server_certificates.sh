#!/bin/bash -x
set -e

echo Generate the service-account certificate and private key...

for instance in $WORKERS $CONTROLLERS; do
  mkdir -p files/${instance}
done

for instance in $WORKERS; do
  DIR="files/${instance}"
  cp ca.pem ${instance}-key.pem ${instance}.pem $DIR
done

for instance in $CONTROLLERS; do
  DIR="files/${instance}"
  cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem $DIR
done