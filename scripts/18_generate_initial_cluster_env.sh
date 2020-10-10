#!/bin/bash -x
set -e

echo Distribute etcd config files among controllers...

CONTROLLERS_LEN=${#CONTROLLERS[@]}

ETCD_INITIAL_CLUSTER=""

ETCD_INITIAL_CLUSTER_ARRAY=()
ETCD_SERVERS_ARRAY=()
ETCD_SERVERS=""

for (( i=1; i<=$CONTROLLERS_LEN; i++ )); do
  instance="${CONTROLLERS[$i]}"
  ETCD_NAME=$instance
  INTERNAL_IP="${CONTROLLERS_IPS[$i]}"
  ETCD_INITIAL_CLUSTER_ARRAY+=("${ETCD_NAME}=https://${INTERNAL_IP}:2380")
  ETCD_SERVERS_ARRAY+=("https://${INTERNAL_IP}:2379")
done

ETCD_SERVERS=${"${ETCD_SERVERS_ARRAY[*]}"// /,}
ETCD_INITIAL_CLUSTER=${"${ETCD_INITIAL_CLUSTER_ARRAY[*]}"// /,}