#!/bin/bash

CLUSTER_NAME=kubernetes-tuxin-cluster
WORKERS=(tux-2 tux-3)
WORKERS_PODS_CIDR=("10.200.2.0/24" "10.200.3.0/24")
WORKERS_IPS=(192.168.1.2 192.168.1.3)
CONTROLLERS=(controller)
CLUSTER_IP_RANGE="10.32.0.0/24"
CLUSTER_CIDR="10.200.0.0/16"
CONTROLLERS_IPS=(192.168.1.3)
DOMAIN="tux-in.com"
KUBERNETES_PUBLIC_ADDRESS=tux-in.com
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
WORKER_IPS_STR=${"${WORKERS_IPS[*]}"// /,}
