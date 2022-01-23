#!/bin/bash
set -eo pipefail

discovery_token_ca_cert_hash="$(grep 'discovery-token-ca-cert-hash' /vagrant/kubeadm.log | head -n1 | awk '{print $2}')"
apiserver_address="$(grep 'kubeadm join' /vagrant/kubeadm.log | head -n1 | awk '{print $3}')"
token="$(grep 'kubeadm join' /vagrant/kubeadm.log | head -n1 | awk '{print $5}')"

# join cluster
sudo kubeadm reset -f
sudo kubeadm join --ignore-preflight-errors=all ${apiserver_address} --token ${token} --discovery-token-ca-cert-hash ${discovery_token_ca_cert_hash}