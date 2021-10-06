## [기초편]기초다지기

### Kubernetes(쿠버네티스) 구성
<img>
- 한 서버는 Master로 쓰고 다른 서버들은 하나 혹은 여러 개의 Node들이 연결이 연결이 된다. 그리고 이것들을 묶어 한 Cluster(클러스터)가 된다.
- Master: 전반적인 기능들을 제어하는 역할이다.
- Node: 자원을 제공한다. 만약 클러스터 내의 자원을 늘리고 싶다면 Node들을 늘리면 된다.
- Namespace: 쿠버네티스 Object들을 독립 된 공간으로 분리되게 만들어 준다. Namespace에는 Pod들이 있고 이 Pod들에게 외부로 연결이 가능하도록 id를 할당해주는 서비스가 있어서 같은 Namespace의 Pod와 연결이 가능하지만 다른 Namespace의 Pod와는 연결이 불가능하다.
- Pod: 최소 배포 단위이다. Pod안에는 여러 컨테이너가 있다. Pod에 문제가 생겨 재생성되면 그 앱들이 날라가기 때문에 Volume을 만든다. 
- Container: 컨테이너 하나 당 하나의 App이 동작한다.
- Volume: Pod의 데이터를 별로도 저장하는 곳이다.
- ResourceQuota / LimitRange: 한 Namespace에서 사용할 수 있는 자원의 양을 한정시킨다.
- ConfigMap / Secret: Pod 생성 시 환경변수 값을 넣어주거나 파일을 마운트를 할 수 있도록 설정을 도와준다.
- Controller: Pod들을 관리해주는 일들을 한다.

#### Controller
- Replication Controller, ReplicaSet: Pod가 죽으면 감지해서 다시 살려주거나 Pod의 개수를 조절(scale)해준다.
- Deployment: 배포 후에 Pod들을 새 버전으로 업그레이드 해준다. 그리고 업그레이드를 하던 중에 문제가 생기면 rollback을 할 수 있도록 도와준다.
- DaemonSet: 한 노드의 Pod가 하나씩만 유지가 되도록 하는 것인데 이렇게 사용을 해야만 하는 모듈들이 존재한다.
- Job: 어떤 특정 작업만하고 종료를 시켜야하는 일을 할 때 Pod가 동작을 하도록 도와준다.
- CrobJob; 특정한 잡업만 하는 Job들을 주기적으로 실행시켜야 할 때 사용한다.

### Kubernetes(쿠버네티스) 특징
- 서비스 효율로 서버가 적어지면 유지보수 비용이 적게 든다.
- Deployment
- Auto Scalling
- Auto Healing

### VM vs Container
- Container(컨테이너)
    - 컨네이터는 컨테이너 이미지를 만들 수 있는데 그 이미지에는 한 서비스와 한서비스를 돌아가는데 필요한 라이브러리들이 들어있어 한 Container에서 컨테이너 이미지에 라이브러리가 있기 때문에 안정적으로 돌아 갈 수 있다.
    - 한 가상화 서비스를 만들 때 모듈별로 쪼개서 컨테이너에 담는 것을 추천
    - 여러 컨테이너를 Pod를 묶을 수 있고 Pod가 배포 단위이다.
    - Docker Hub: 여러가지의 컨테이너 이미지를 올려놓은 곳.
    - namespace와 cgroups을 이용해서 격리를 한다.
    - namespace: mnt, pid, net, ipc, uts, user -> 커널에 관련된 영역을 분리해준다.
    - cgroups: memory, CPU, I/O, network -> 자원과 관련되 영역을 분리해준다.
- docker와 같은 가상화 Solution들은 OS에서 제공하는 자원 격리 기술을 이용해 Container라는 단위로 서비스를 분리할 수 있게 만들어준다.
- Container가 깔려 있는 OS에서는  개발 환경에 대한 걱정없이 배포가 가능하다.
- 장점
    -  시스템 구조적으로 Container는 한 OS를 공유를 하고 VM은 각각한 OS를 끼고 있어야 하기 때문에 Container가 빠르다.
-단점 
    - VM는 게스트 OS, 호스트 OS와는 완벽하게 분리가 되어 있지만 Container는 하나가 뚫려서 OS 영역에 접근하게 되면 보안에 문제가 생길 수 있다.
