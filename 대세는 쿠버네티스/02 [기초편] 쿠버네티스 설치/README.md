### Setting K8S (CentOS 7)
#### Download
1. CentOS Image 다운
2. k8s-master, k8s-node1, k8s-slave 3개의 VM 만들어주기(master의 코어는 무조건 2개 이상이여야 한다.)
    - k8s-master: 4core, 4GB, 20GB
    - k8s-node1: 2core, 2GB, 20GB
    - k8s-node2: 2core, 2GB, 20GB
#### Pre-Setting
1. SELinux 설정
```
$setenforce 0
$sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
$sestatus
...
Current mode:permissive
...
```
2. 방화벽 해제
```
systemctl stop firewalld && systemctl disable firewalld
systemctl stop NetworkManager && systemctl disable NetworkManager
```
3. Swap 비활성화
```
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
```
4. iptables 커널 옵션 활성화
```
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
5. 쿠버네티스 YUM Repository 설정
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
6. Centos Update
```
yum update -y
```
7. hosts 등록
    - ip는 VM 네트워크 설정 당시 설정한 IP
```
cat << EOF >> /etc/hosts
192.168.75.133 k8s-master
192.168.75.134 k8s-node1
192.168.75.135 k8s-node2
EOF
```
#### Installation
1. Docker 설치
```
yum install -y yum-utils device-mapper-persistent-data lvm2 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update -y && yum install -y docker-ce-18.06.2.ce

mkdir -p /etc/systemd/system/docker.service.d
```
2. Kubernetes 설치
```
yum install -y --disableexcludes=kubernetes kubeadm-1.15.5-0.x86_64 kubectl-1.15.5-0.x86_64 kubelet-1.15.5-0.x86_64
```
#### Master 설정
1. 도커 및 쿠버네티스 실행
```
systemctl daemon-reload
systemctl enable --now docker
docker run hello-world
systemctl enable --now kubelet
```
2. 쿠버네티스 초기화 명령 실행
    - master 결과: `kubeadm join 192.168.75.133:6443 --token 19zx2v.15rjjnquni2w7p4e --discovery-token-ca-cert-hash sha256:8a3fe31ec9a914e6eaf2fc9dc6c08403f504b80c37ba3bc309ecbb015a930980`
`
```
kubeadm init --pod-network-cidr=20.96.0.0/12 --apiserver-advertise-address=192.168.75.133
```
3. 환경변수 설정
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
4. kubectl 자동완성 기능 설치
```
yum install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```
#### Node 설정
1. 도커 및 쿠버네티스 실행
```
systemctl daemon-reload
systemctl enable --now docker
systemctl enable --now kubelet
```
2. Node 연결
```
kubeadm join 192.168.75.133:6443 --token 19zx2v.15rjjnquni2w7p4e --discovery-token-ca-cert-hash sha256:8a3fe31ec9a914e6eaf2fc9dc6c08403f504b80c37ba3bc309ecbb015a930980
```
3. Node 연결 확인(Master에서 하기!)
```
kubectl get nodes
```
#### Networking
1. Calico 설치
```
curl -O https://docs.projectcalico.org/v3.9/manifests/calico.yaml
sed s/192.168.0.0\\/16/20.96.0.0\\/12/g -i calico.yaml
kubectl apply -f calico.yaml

kubectl get pods --all-namespaces
```
#### Dashboard 
1. Dashboard 설치
```
kubectl apply -f https://kubetm.github.io/documents/appendix/kubetm-dashboard-v1.10.1.yaml
```
2. 백그라운드로 proxy 띄우기
```
nohup kubectl proxy --port=8001 --address=192.168.75.133 --accept-hosts='^*$' >/dev/null 2>&1 &
```
3. 접속 URL
- [http://192.168.75.133:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/]로 접속