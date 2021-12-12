1. docker Cgroup 이 systemd 로 설정되어있을 경우

/etc/docker/daemon.json 파일에 아래 문구 추가한다.

{
	"exec-opts": ["native.cgroupdriver=systemd"]
}
그리고
systemctl daemon-reload
systemctl restart docker

2. 로그 확인

- 'journalctl -xeu kubelet' 

이 명령어를 실행 하면 아래와 같이 로그가 남았다. 

Apr 30 22:19:38 master kubelet: W0430 22:19:38.226441    2372 cni.go:157] Unable to update cni config: No networks found in /etc/cni/net.d
Apr 30 22:19:38 master kubelet: E0430 22:19:38.226587    2372 kubelet.go:2067] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
 

내 경우에는 위에 2.  /env/environment 설정 에 보면 **no_proxy** 항목에 현재 K8S 가 설치된 Machine 의 IP 를 추가했더니 해결이 되었다.

- kubeadm join 했는데 다음과 같이 나올 경우

[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
    [ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists
    [ERROR Port-10250]: Port 10250 is in use
    [ERROR FileAvailable--etc-kubernetes-pki-ca.crt]: /etc/kubernetes/pki/ca.crt already exists
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
    VM 에서 다음과 같이 kubeadm join 을 했는데 에러가 났을경우 (node가 2개인데 2번째 노드 구성시)

    kubeadm reset 을 한번 실행하고 다시 join 명령어를 실행해준다.