###initialize the system####
sudo swapoff -a

sudo modprobe overlay

sudo modprobe br_netfilter

sudo sysctl -w net.bridge.bridge-nf-call-ip6tables = 1
sudo sysctl -w net.bridge.bridge-nf-call-iptables = 1
sudo sysctl -w net.ipv4.ip_forward=1

sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

###INSTALL THE CONTAINER RUNTIME-containerd
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

export OS_VERSION=xUbuntu_20.04
export CRIO_VERSION=1.23

curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

sudo apt update

sudo apt install -y cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio

sudo systemctl status crio

sudo apt install -y containernetworking-plugins

sudo systemctl restart crio

sudo apt install -y cri-tools

###INSTALL KUBERNETES
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


sudo kubeadm init


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl cluster-info
kubectl get nodes


curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
kubectl apply -f calico.yaml


kubectl get pods -n kube-system
