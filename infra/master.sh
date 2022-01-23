#!/bin/bash
set -eo pipefail

# start cluster
sudo kubeadm reset -f
sudo kubeadm init --ignore-preflight-errors=all --apiserver-advertise-address "10.0.3.15" --pod-network-cidr="10.244.0.0/16" --token-ttl 0 | tee /vagrant/kubeadm.log

# To make kubectl work for your non-root user
mkdir -p $HOME/.kube
sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo systemctl restart kubelet

#enable schedule
kubectl taint nodes --all node-role.kubernetes.io/master-

#deploy flannel network
curl -s https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml -o /vagrant/kube-flannel.yml
kubectl apply -f /vagrant/kube-flannel.yml