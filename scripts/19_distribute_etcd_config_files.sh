#!/bin/bash -x
set -e

echo Distribute etcd config files among controllers...

CONTROLLERS_LEN=${#CONTROLLERS[@]}

for (( i=1; i<=$CONTROLLERS_LEN; i++ )); do
  instance="${CONTROLLERS[$i]}"
  INTERNAL_IP="${CONTROLLERS_IPS[$i]}"
  ETCD_NAME=$instance
  DIR="files/${instance}"
  ETCD_DIR="${DIR}/etc/etcd"
  mkdir -p $ETCD_DIR
  cp ca.pem kubernetes-key.pem kubernetes.pem $ETCD_DIR
  SYSTEMDIR_DIR="${DIR}/etc/systemd/systemd"
  mkdir -p $SYSTEMDIR_DIR
cat <<EOF | tee ${SYSTEMDIR_DIR}/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCD_INITIAL_CLUSTER} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done