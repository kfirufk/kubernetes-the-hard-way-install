#!/bin/bash -x
set -e

echo Generate the service-account certificate and private key...

for instance in $WORKERS; do
  DIR="files/${instance}"
  cp ${instance}.kubeconfig kube-proxy.kubeconfig $DIR
done

for instance in $CONTROLLERS; do
  DIR="files/${instance}"
  cp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig $DIR
done