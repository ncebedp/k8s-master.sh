#!/bin/bash

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.ipv4.ip_forward

sudo swapoff -a

sudo apt-get update

sudo apt-get install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update

  sudo apt-get install containerd.io -y

  containerd config default > /etc/containerd/config.toml 


# Define the file path
CONFIG_FILE="/etc/containerd/config.toml"

# Check if the file exists
if [ -f "$CONFIG_FILE" ]; then
    # Update the SystemdCgroup value to true
    sed -i 's/^SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG_FILE"

    echo "Updated SystemdCgroup to true in $CONFIG_FILE"
else
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

sudo systemctl restart containerd

sudo apt-get update -y

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update -y

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

# kubeadm init --apiserver-advertise-address 75.119.134.68 --pod-network-cidr 10.244.0.0/16 --cri-socket unix:///var/run/containerd/containerd.sock
kubeadm init --apiserver-advertise-address 192.168.1.100 --pod-network-cidr 10.244.0.0/16 --cri-socket unix:///var/run/containerd/containerd.sock



mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.30/net.yaml  

