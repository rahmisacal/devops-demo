#!/bin/bash
set -eo pipefail

# bridged traffic to iptables is enabled for kube-router.
cat >> /etc/ufw/sysctl.conf <<EOF
net/bridge/bridge-nf-call-ip6tables = 1
net/bridge/bridge-nf-call-iptables = 1
net/bridge/bridge-nf-call-arptables = 1
EOF

# disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Update the apt package index
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker download
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] "https://download.docker.com/linux/ubuntu" \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#Download the Google Cloud public signing key and Add the Kubernetes apt repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat >> /etc/apt/sources.list.d/kubernetes.list <<EOF
deb "https://apt.kubernetes.io/" kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet=1.19.2-00 kubeadm=1.19.2-00 kubectl=1.19.2-00

# https://github.com/kubernetes/kubernetes/issues/45487
echo 'User=root' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# enable and restart services
sudo systemctl daemon-reload
sudo systemctl enable kubelet && sudo systemctl restart kubelet
sudo systemctl enable docker && sudo systemctl restart docker
sudo usermod -aG docker vagrant

# ssh configuration
cat /vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
cp /vagrant/id_rsa /home/vagrant/.ssh/id_rsa
chmod 600 /home/vagrant/.ssh/id_rsa
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# /etc/hosts
echo "10.0.3.15 master" >> /etc/hosts
echo "10.0.3.16 node1" >> /etc/hosts
echo "10.0.3.17 node2" >> /etc/hosts