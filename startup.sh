# Installation via AlmaLinux 9

# Mettre SELinux en mode permissif (le désactiver efficacement)

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Installation de ContainerD

#sudo wget https://github.com/containerd/containerd/releases/download/v1.6.20/containerd-1.6.20-linux-amd64.tar.gz
#sudo tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz
#sudo rm -f containerd-1.6.2-linux-amd64.tar.gz

#sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /usr/local/lib/systemd/system/

sudo yum install -y dnf-plugins-core
sudo yum config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

#sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Installation de RunC

#sudo wget https://github.com/opencontainers/runc/releases/download/v1.1.6/runc.amd64
#sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Installation des plugin CNI

sudo wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz
sudo rm -f cni-plugins-linux-amd64-v1.2.0.tgz

# Installation de KubeADM

sudo cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Installation kubeadm & kubelet

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet