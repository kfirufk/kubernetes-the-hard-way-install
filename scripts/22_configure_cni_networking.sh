#!/bin/bash -x
set -e

echo Distribute etcd config files among controllers...

WORKERS_LEN=${#WORKERS[@]}

POD_CIDR=""

for (( i=1; i<=$WORKERS_LEN; i++ )); do
  instance="${WORKERS[$i]}"
  ETCD_NAME=$instance
  INTERNAL_IP="${CONTROLLERS_IPS[$i]}"
  DIR="files/${instance}"
  SYSTEMDIR_DIR="${DIR}/etc/systemd/systemd"
  mkdir -p $SYSTEMDIR_DIR
  CNI_NET_DIR="${DIR}/etc/cni/net.d"
  mkdir -p $CNI_NET_DIR
cat <<EOF | tee $CNI_NET_DIR/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
cat <<EOF | tee $CNI_NET_DIR/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF
CONTAINERD_CONF_DIR="$DIR/etc/containerd"
mkdir -p $CONTAINERD_CONF_DIR
cat << EOF | tee $CONTAINERD_CONF_DIR/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

cat <<EOF | tee $SYSTEMDIR_DIR/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

KUBELET_DIR="$DIR/var/lib/kubelet"
KUBELET_CONFIG_DIR="$KUBELET_DIR/kubeconfig"
VAR_LIB_KUBERNETES="$DIR/var/lib/kubernetes"
mkdir -p $KUBELET_CONFIG_DIR
cp "${instance}-key.pem" "${instance}.pem" $KUBELET_DIR
cp "${instance}.kubeconfig" $KUBELET_CONFIG_DIR
cp ca.pem $VAR_LIB_KUBERNETES

cat <<EOF | tee ${KUBELET_DIR}/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cat <<EOF | tee $SYSTEMDIR_DIR/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

KUBEPROXY_CONFIG="$DIR/var/lib/kube-proxy"
mkdir -p $KUBEPROXY_CONFIG

cp kube-proxy.kubeconfig $KUBEPROXY_CONFIG/kubeconfig

cat <<EOF | tee $KUBEPROXY_CONFIG/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: ${CLUSTER_CIDR}
EOF

cat <<EOF | tee $SYSTEMDIR_DIR/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

done
