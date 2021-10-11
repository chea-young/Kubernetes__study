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

### Pod 실습
<img src="./img/Pod-1.pmg" />
- 대시보드에 '+생성' 버튼을 누르면 생성할 수 있다.
<img src="./img/Pod-1.pmg" />
- Pod 생성 후 'Exec' 버튼을 누르면 Pod안의 Container 안으로 들어갈 수 있다

#### ReplicationController
- Pod를 관리해주는 역할을 하는데 Pod가 죽으면 생성해주는 역할을 하게 된다.
-> 그래서 삭제를 하게 되면 바로 삭제되지 않고 다른 새로운 ip를 가진 새 파드를 생성한다.
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: replication-1
spec:
  replicas: 1
  selector:
    app: rc
  template:
    metadata:
      name: pod-1
      labels:
        app: rc
    spec:
      containers:
      - name: container
        image: kubetm/init

``` 
#### 라벨 이용하기
- service-1를 type:web으로 만들면 2개의 node만 연결된다.
- service-2를 producetion에게 돌아가고 있는 Pod들 3개가 연결된다.
```
# Pod (web, db, server, web-producetion, db-producetion, server-producetion)
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
  labels:
    type: web
    lo: dev
spec:
  containers:
  - name: container
    image: kubetm/init

# Service -1
apiVersion: v1
kind: Service
metadata:
  name: svc-for-wed
spec:
  selector:
    type: web
  ports:
  - port: 8080

# Service -2
apiVersion: v1
kind: Service
metadata:
  name: svc-for-producetion
spec:
  selector:
    lo: producetion
  ports:
  - port: 8080
```
#### Node Schedule
- `kubernetes.io/hostname: k8s-node1`이 node1에 있는 lable로 Pod-1로 생성하면 node1에 생성이 된다
```
#Pod-1
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

### Service
- 서비스는 자신의 Cluster IP를 가지고 있다. 그리고 이 서비스를 Pod에 연결하면 서비스의 IP를 통해서도 Pod와 접근이 가능하게 된다.
- Pod는 삭제되고 재생성되기 쉽지만 서비스는 사용자가 직접 지우지 않는 이상 삭제되지 않아서 서비스의 P로 파드에 접근하는 것이 다르다. 근데 서비스의 종류마다 접근하는 방식이 다르다.
- 접근 방식
  <img>
  - ClusterIP : 쿠버네티스 클러스터내에서만 접근이 가능한 IP이다. 파드 IP 특성과 같아서 클러스터 내의 모든 Object는 접근할 수 있지만 클러스터 외부에서는 접근이 불가능하다.
    - 외부에서 접근할 수 없고 클러스터내에서만 사용하는 IP로 이것에 접근할 수 있는 대상은 클러스터 내의 운영자와 같은 인가된 사용자이다. 주된 작업은 클러스터 대시보드를 작업을 하거나 각 Pod의 서비스 상태를 디버깅 작업을 한다. 
  - NodePort: 저절로 서비스에 클러스터 IP가 할당되어 ClusterIP 기능이 포함되어 있으며 클러스터 쿠버네티스에 있는 모든 Node에 똑같은 포트가 할당이 되서 외부에서 IP의 포트로 접속을 하면 서비스에 연결이 된다. 또한 자신들에게 연결되는 있는 Pod에게 트래픽 전달이 가능하다.
    - 물리적인 호스트에 IP를 통해서 Pod에 접근을 할 수가 있다. 
  ```
  apiVersion: v1
  kind: Service
  metadata:
    name: svc-2
  spec:
    selector:
      app: pod
    ports:
    - port: 9000
      targetPort: 8080
      nodePort: 30000
    type: NodePort
    externalTrafficPolicy: Local
  ```
    - nodePort는 30000~32767 포트를 할당할 수 있다. 
    - `externalTrafficPolicy: Local`을 주면 특정 노드 포트에 IP 접근을 하는 트래픽은 서비스가 해당 노드위에 올려져 있는 파드한테만 트래픽을 전달을 해준다. 
  - Load Balancer: Node Port의 성격을 그대로 가지고 있다. 그리고 Load Balancer가 생겨서 각각의 Node에 트래픽을 분산시켜준다. Load Balancer에 접근을 하기 위한 외부 접속 IP 주소는 별도로 외부접속 IP를 설정을 해주어야 한다.
    - 실제 외부에 서비스를 노출시키려면 이것을 이용해야 내부 IP가 노출되지 않고 외부 IP를 통해서 안정적으로 서비스를 노출시킬 수 있다.
    ```
    apiVersion: v1
    kind: Service
    metadata:
      name: svc-3
    spec:
      selector:
        app: pod
      ports:
      - port: 9000
        targetPort: 8080
      type: LoadBalancer
    ```
### 실습 - Service
- ClusterIP 실습: `curl 10.104.212.151:9000/hostname`를 master에 입력 시 파드의 hostname가 나옴.
```
#Pod -1
apiVersion: v1
kind: Pod
metadata:
  name: pod-1-service
  labels:
     app: pod
spec:
  nodeSelector:
    kubernetes.io/hostname: k8s-node1
  containers:
  - name: container
    image: kubetm/app
    ports:
    - containerPort: 8080

# Servuce -1
apiVersion: v1
kind: Service
metadata:
  name: svc-1-service
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
```
- NodePort 실습: 생성시 내부 엔드포인트에 클러스터 IP로 접근을 했을 때 연결할 수 있는 포트, 노드로 접근을 했을 때 쓸 수 있는 포트이다. `curl 192.168.75.134:30000/hostname` 시 트래픽을 고르게 분포하여 파드 2개가 번갈아서 나온다. 
```
# NodePort -1
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
    nodePort: 30000
  type: NodePort
  externalTrafficPolicy: Local
```
- Load Balancer: `kubectl get service svc-3`해보면 외부 IP를 할당해주는 플러그인이 없어서 'pending' 상태이다
```
apiVersion: v1
kind: Service
metadata:
  name: svc-3
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
  type: LoadBalancer
```

### Volume
<img>
- emptyDir: 컨테이너들끼리 데이터를 공유하기 위해서 볼륨을 사용한다. Pod 생성 시 만들어지고 삭제 시 없어지기 때문에 일시적인 목적을 가진 내용만 넣는 것이 좋다. 
  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: pod-volume-1
  spec:
    containers:
    - name: container1
      image: kubetm/init
      volumeMounts:
      - name: empty-dir
        mountPath: /mount1
    - name: container2
      image: kubetm/init
      volumeMounts:
      - name: empty-dir
        mountPath: /mount2
    volumes:
    - name : empty-dir
      emptyDir: {}
  ```
    - 컨테이너가 각 다른 이름의 볼륨에 마운트하고 있지만 실제로는 똑같은 볼륨에 마운트하고 있는 것이다.
- hostPath: Pod들이 죽어도 Node에 있는 데이터는 사라지지 않는다. Pod가 죽어서 재 생성이 될 때 다른 노드에 생성이 된다면 이전에 노드에 있던 볼륨을 마운트 할 수 없게 된다(하지만 노드를 추가할 때마다 똑같은 경로를 만들어서 직접 같은 Path끼리 마운트를 시켜주면 문제는 없어진다- 쿠버네티스의 역할이 아닌 운영자가 해줘야하는 입장).
  - hostPath라는 속성이 존재한다. host에 있는 path는 pod가 생성이 되기 전에 존재해야 에러가 나지 않는다.
- PVC/PV (Persisitent Volume Claim/Persistent Volume)
  - Pod는 PVC를 이용해 PV와 연결된다. 
  - User 영역(pod, PVC)과 Admin 영역(PV, Volume)이 나눠진다.
  - 동작
    1. 최초의 Admin이 PV를 만들어 놓는다.
    2. 사용자가 PVC 생성
    3. 쿠버네티스가 PVC 내용에 맞는 적절한 Volume에 연결을 해준다.
    4. Pod를 만들 때 PVC를 사용하면 된다. 
  ```
  #PVC
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-01
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 1G
    storageClassName: ""
  ```
  - `storageClassName: ""` 이렇게 되면 기존에 있는 PV가 선택이 될 수 있다.
  ```
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-04
    labels:
      pv: pv-04
  spec:
    capacity:
      storage: 2G
    accessModes:
    - ReadWriteOnce
    local:
      path: /node-v
    nodeAffinity:
      required:
        nodeSelectorTerms:
        - matchExpressions:
          - {key: kubernetes.io/hostname, operator: In, values: [k8s-node1]}
  ```
  - k8s-node1라고 라벨링이 되어있는 노드 위에만 무조건 만들어진다는 뜻이다. 그래서 Pod는 무조건 이 node위에만 생성되게 되는 것이다.