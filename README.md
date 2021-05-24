# Kubernetes__study

### Pod
- 컨테이너를 묶어서 관리하므로 보통 여러 개 컨테이녀로 구성
- 컨테이너 여러 개를 한꺼번에 관리 할 때는 컨테이너 마다 역할을 부여 가능
- Pod 하나가 컨테이너들이 같은 목적으로 자원을 공유
- Pod  하나 안에 있는 컨테이너들이 IP 하나를 공유. 즉, 외부에서 이 파드에 접근 할 때는 한 IP로 접근하며 파드 안 컨테이너와 통신할 때는 컨테이너마다 다르게 설정한 포트를 사용한다.

### 커맨드 설명
  - docker search A :  A에 대한 docker명령과 함께 명령을 사용하여 Docker Hub에서 사용 가능한 이미지를 검색
  - docker pull A: A 이미지를 컴퓨터에 다운로드
  - docker run -it A: A의 최신 이미지를 사용하여 컨테이너를 실행


### 참고 사이트 
  -  How To Install and Use Docker on Ubuntu 20.04: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
  -  Ubuntu 18.04 에서 Kubernetes 설치하기: https://www.skyer9.pe.kr/wordpress/?p=640
