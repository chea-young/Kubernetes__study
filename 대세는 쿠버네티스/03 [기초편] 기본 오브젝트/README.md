### Object - Pod
- Pod 안에는 하나의 독립적인 서비스를 구성할 수 있는 컨테이너들이 있다. 그 컨테이너들은 서비스가 연결될 수 있도록 포트를 가지고 있지만 한 컨테이너가 여러 개의 포트를 가질 수는 있지만 한 Pod 내에서 중복이 되지는 않는다.
- 한 Pod 안에서는 한 호스트라고 보고 컨테이너끼리 [localhost:포트]로 통신이 가능하다.
- Pod가 생성 될 때 고유의 IP가 생성이 된다. 쿠버네틱스에서만 이 IP를 통해서 이 Pod에 접근을 할 수 있다.
- Pod는 여러 개의 Node 중 하나의 Node 위에 올라간다.
- Pod 생성을 위한 YAML 파일 예시
```
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
spec:
  containers:
  - name: container1
    image: kubetm/p8000
    ports:
    - containerPort: 8000
  - name: container2
    image: kubetm/p8080
    ports:
    - containerPort: 8080
```
    - 2개의 컨테이너가 생성된다. 
#### Label
- Pod 뿐만 아니라 모든 Object에 달 수가 있다.
- 'key:value'가 한 쌍이다.
- 한 Pod에는 여러 개의 Label을 달 수가 있다.
- 목적에 따라 Object끼리 분류를 하고 그 분류된 Object들만 따로 연결을 할 수 있도록 도와줄 수 있다.
```
apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  selector:
    type: web
  ports:
  - port: 8080
```
    - 라벨이 같은 것 끼리 묶어서 이용할 수도 있다.
#### Node Schedule
- 직접 지정해서 Pod가 Node에 올라가는 방법과 쿠버네티스가 자동적으로 선택을 해주는 방법 2가지가 있다.
- 직접 지정
    - Node 생성 시 라벨을 붙어 Pod와 연결한다.
    ```
    apiVersion: v1
    kind: Pod
    metadata:
    name: pod-3
    spec:
    nodeSelector:
        kubernetes.io/hostname: k8s-node1
    containers:
    - name: container
      image: kubetm/init
    ```
- 자동 지정
    - 쿠버네티스의 스케줄러가 판단을 해서 지정을 해준다. Node에는 전체 사용 가능한 자원양이 있기 때문에 이것에 따라 자동 스케줄링한다.
    ```
    apiVersion: v1
    kind: Pod
    metadata:
    name: pod-4
    spec:
    containers:
    - name: container
        image: kubetm/init
        resources:
        requests:
            memory: 2Gi
        limits:
            memory: 3Gi
    ```
        - limit: memory는 초과 시 Pod를 종료시키지만 CPU경우 초과 시 request로 낮추고 종료하지는 않는다.
