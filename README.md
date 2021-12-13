# Kubernetes__study
- 쿠버네티스를 혼자 공부하면서 그리고 'Inflearn', 김태민님의 대세는 쿠버네티스 강의를 들으면서 정리하는 Repository
## 전체 목차
## 대세는 쿠버네티스
1. Introduction
[기초편] 기초 다지기
1. Why Kubernetes?
2. VM vs Container
3. VM vs Container

### 클러스터
- 쿠버네티스의 여러 리소스를 관리하기 위한 집합체
- 클러스터는 마스터와 노드의 그룹으로 구성
- 쿠버네티스 리소스 중에서 가장 큰 개념은 노드, 노드는 쿠버네티스 클러스터의 관리 대상으로 등록된 도커 호스트로, 컨테이너가 배치되는 대상
- 클러스터에는 클러스터 전체를 관리하는 서버인 마스터가 적어도 하나 이상 있어야 한다.

<br>

### Pod
- 컨테이너를 묶어서 관리하므로 보통 여러 개 컨테이너로 구성
- Pod에 단일 컨테이너만 있을 경우에는 일반적인 방식으로 컨테이너를 관리해도 되지만 여러 개를 한꺼번에 관리할 경우에는 pod로 모두 노드 하나 안에서 컨테이너들이 실행.
- 컨테이너 여러 개를 한꺼번에 관리 할 때는 컨테이너 마다 역할을 부여 가능
- Pod 하나가 컨테이너들이 같은 목적으로 자원을 공유
- Pod  하나 안에 있는 컨테이너들이 IP 하나를 공유. 즉, 외부에서 이 파드에 접근 할 때는 한 IP로 접근하며 파드 안 컨테이너와 통신할 때는 컨테이너마다 다르게 설정한 포트를 사용
- 쿠버네티스의 마스터 노드에는 Pod 할당이 되지 않는다. 왜냐하면 마스터 노드에는 Taints로 NoSchedule이라는 효과가 적용되어 있기 때문이다.  
  - 만약 마스터 노드에 파드를 할당하고 싶다면 Pod나 depolyment의 spec에 Tolerations을 생성

<br>

### 커맨드 설명
  - docker search A :  A에 대한 docker명령과 함께 명령을 사용하여 Docker Hub에서 사용 가능한 이미지를 검색
  - docker pull A: A 이미지를 컴퓨터에 다운로드
  - docker run -it A: A의 최신 이미지를 사용하여 컨테이너를 실행
  - docker rmi 태그이름/이미지ID: 이미지 삭제
  - kubectl run pod이름 --image=이미지이름
  - kubectl get pods: pod 상태 확인
  - kubeadm init --apiserver-advertise-address=<A> --pod-network-cidr=[APISERVER_IP]:[APISERVER_PORT]: A는 k8s 오버레이 네트워크 설정을 위해서 [APISERVER_IP]:[APISERVER_PORT]는 외부에서 접속가능한 주소를 설정하기 위해서 사용 [마스터 노드 설정 및 초기화]
  - kubeadm join [APISERVER_IP]:[APISERVER_PORT] --token [TOKEN] --discover-token-ca-cert-hash [CA_CERT] : [TOKEN]은 'kubeadm token create --print-join-command'를 마스터 노드에서 실행 시 생성되는 토큰을 사용하고 [CA_CERT]는 
  " openssl x509 -pubkey \ -in /etc/kubernetes/pki/ca.crt | openssl rsa \ -pubin -outform der 2>/dev/null | openssl dgst \ -sha256 -hex | sed 's/^.* //' "를 마스터 노드에서 생성시 나오는 CA CERT를 사용한다. [Worker 노드 설정 및 초기화]

### docker image 생성 후 docker hub에 올리기
1. Dockerfile 생성
  -  Dockerfile  명령어
      - FROM  <이미지> 혹은 <이미지:태그> : 기존 이미지 위에 새로운 이미지를 중첩해서 여러 단계의 이미지 층을 쌓는 것.
      - WORKDIR <이동할 경로>: cd처럼 컨테이너 상에서 작업 디렉토리로 전환을 위해서 사용한다.
      - RUN ["<커맨드>", "<파라미터1>", "<파라미터2>"] or RUN <전체 커맨드>: shell에서 커맨드를 실행하는 것 처럼 이미지 빌드 과정에서 필요한 커맨드를 싱행하기 위해서 사용된다. 보통 특정 소프트 웨어 설치를 위해서 사용.
      - ENTRYPOINT ["<커맨드>", "<파라미터1>", "<파라미터2>"] or ENTRYPOINT <전체 커맨드>:  이미지를 컨테이너로 띄울 때 항상 실행되어야 하는 커맨드를 지정할 때 사용하는 것.이 명령문을호 지정된 커맨드가 실행되고, 이 커맨드로 실행된 프로세스가 죽을 때, 컨테이너로 따라서 종료된다.
      - CMD ["<커맨드>","<파라미터1>","<파라미터2>"] or CMD ["<파라미터1>","<파라미터2>"] or CMD <전체 커맨드>: 해당 이미지를 컨테이너로 띄울 때 디폴트로 실행할 커맨드나 ENTRYPOINT 명령문으로 지정된 커맨드에 디폴트로 넘길 파라미터를 지정할 때 사용한다.
      - EXPOSE <포트> or EXPOSE <포트>/<프로토콜>: 네트워크 상에서 컨테이너로 들어오는 트래픽(traffic)을 리스닝(listening)하는 포트와 프로토콜를 지정하기 위해서 사용한다. 프로토콜은 TCP와 UDP 중 선택할 수 있는데 지정하지 않으면 TCP가 기본으로 사용된다.
      - ENV <키> <VALUE>> ENV <키>=<VALUE>: 환경변수를 설정하기 위해서 사용한다. 이렇게 설정된 환경 변수는 이미지 빌드시에도 혹은 해당 컨테이너에서 돌아가는 애플리케이션도 접근가능하다.
      - AGE
      - COPY
2. docker build -t userid/이름:버전 .
3. docker login
4. docker push  userid/이름:버전
5. docker images
  - docker  image가 생성된 것을 확인할 수 있다.
6. docker run [이름]
  - docker를 실행시킬 수 있다.
  - docker run -itd --name [생성하고 싶은 container 이름] [image 이름] 
  - docker exec -it [container이름 or ID] bash
    - 컨테이너에 접속 할 수 있다.
### 참고 사이트 
  -  How To Install and Use Docker on Ubuntu 20.04: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
  -  Ubuntu 18.04 에서 Kubernetes 설치하기: https://www.skyer9.pe.kr/wordpress/?p=640

### 오류
- deb http://apt.kubernetes.io/ kubernetes-xenial main
  - echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
  -  sudo apt-get update
- [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
  -  sudo docker info |grep -i cgroup
    - Cgroup Driver: cgroupfs -> 이거 일 경우 고치기
  - sudo nano /usr/lib/systemd/system/docker.service
  - ExecStart=/usr/bin/dockerd --exec-opt native.cgroupdriver=systemd 추가
  - sudo systemctl daemon-reload
  - sudo systemctl restart docker
  -sudo docker info |grep -i cgroup: Cgroup Driver:systemctl 으로 수정됨.

#### PC
- TOKEN: ijxdl4.sepbo05on3rty056
- CA CERT: 6355e9587eb094a2f88f4b6726b3547aabd7a4d294968d148ed7f50247026868
kubeadm join 220.67.124.124:6443 --token ijxdl4.sepbo05on3rty056  \
    --discovery-token-ca-cert-hash sha256: 6355e9587eb094a2f88f4b6726b3547aabd7a4d294968d148ed7f50247026868

#### 참고 링크
- k8s 클러스터 구축하기 - #1 VirtualBox[https://coffeewhale.com/kubernetes/cluster/virtualbox/2020/08/31/k8s-virtualbox/]