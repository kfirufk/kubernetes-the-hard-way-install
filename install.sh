#!/bin/bash -x
set -e
rm -rf work
mkdir -p work
cd work
source ../scripts/env.sh

#verify etcd cluster working
#sudo ETCDCTL_API=3 etcdctl member list \
#  --endpoints=https://127.0.0.1:2379 \
#  --cacert=/etc/etcd/ca.pem \
#  --cert=/etc/etcd/kubernetes.pem \
#  --key=/etc/etcd/kubernetes-key.pem

#WORKERS_LEN=${#WORKERS[@]}

#for (( i=1; i<=$WORKERS_LEN; i++ )); do
#  instance="${WORKERS[$i]}"
#  INTERNAL_IP="${WORKERS_IPS[$i]}"
#  echo instance $instance $INTERNAL_IP
#done
#exit

source ../scripts/01_certificate_authority.sh
source ../scripts/02_admin_client_certificate.sh
source ../scripts/03_kubelet_client_certificate.sh
source ../scripts/04_controller_manager_client_certificate.sh
source ../scripts/05_kube_proxy_client_certificate.sh
source ../scripts/06_scheduler_client_certificate.sh
source ../scripts/07_kubernetes_api_server_certificate.sh
source ../scripts/08_service_account_key_pair.sh
source ../scripts/09_distribute_the_client_and_server_certificates.sh
source ../scripts/10_generate_kubeconfig_for_each_worker.sh
source ../scripts/11_generate_kube_proxy_config_file.sh
source ../scripts/12_generate_kube_controller_manager_config_file.sh
source ../scripts/13_kube_scheduler_config_files.sh
source ../scripts/14_admin_kubernetes_config_files.sh
source ../scripts/15_distribute_kubernetes_config_files.sh
source ../scripts/16_generate_data_encryption_key.sh
source ../scripts/17_distribute_data_encryption_key_to_controllers.sh
source ../scripts/18_generate_initial_cluster_env.sh
source ../scripts/19_distribute_etcd_config_files.sh
source ../scripts/20_bootstrapping_controller_binaries.sh
source ../scripts/21_rbac_for_kubelet_authorization.sh
source ../scripts/22_configure_cni_networking.sh
