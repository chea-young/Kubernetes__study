## [기초편]기초다지기

### Kubernetes(쿠버네티스)
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
