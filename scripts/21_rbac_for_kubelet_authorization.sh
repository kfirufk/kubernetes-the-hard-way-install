#!/bin/bash -x
set -e

echo Distribute etcd config files among controllers...

CONTROLLERS_LEN=${#CONTROLLERS[@]}


for (( i=1; i<=$CONTROLLERS_LEN; i++ )); do
  instance="${CONTROLLERS[$i]}"
  ETCD_NAME=$instance
  INTERNAL_IP="${CONTROLLERS_IPS[$i]}"

  DIR="files/${instance}/kube-config-to-execute"

  mkdir -p $DIR

cat <<EOF | tee $DIR/01_kube-apiserver-to-kubelet.yml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat <<EOF | tee $DIR/02_kube-apiserver-to-kubelet-bind-clusterole-to-kubernetes.yml

EOF
done

ETCD_SERVERS=${"${ETCD_SERVERS_ARRAY[*]}"// /,}
ETCD_INITIAL_CLUSTER=${"${ETCD_INITIAL_CLUSTER_ARRAY[*]}"// /,}