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

### Volume 실습
- emptyDir 실습
   - Pod 생성 후 컨테이너로 들어가 `ls`로 확인 후 `mount | grep mount1`로 마운트가 되었는지 확인한다.
   - mount 폴더에 들어가 `echo "file context" >> file.txt` 이렇게 폴더 생성 후 다른 컨테이너의 마운트 폴더에 확인해보면 동일한 파일이 존재하는 것을 확인할 수 있다.
```
#Pod
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
- hostPath 실습
   - `echo "file context" >> file.txt`를 한 컨테이너에 마운트 된 폴더에 파일을 만들어서 다른 파드에 존재하는지 확인하고 실제 k8s-node3에 존재하는지도 확인한다.
```
#Pod 
apiVersion: v1
kind: Pod
metadata:
  name: pod-volume-3
spec:
  nodeSelector: # node 지정 -> 만약 하지 않으면 자원 사정을 보고 스케줄러가 할당
    kubernetes.io/hostname: k8s-node3
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: host-path
      mountPath: /mount1
  volumes:
  - name : host-path
    hostPath:
      path: /node-v
      type: DirectoryOrCreate # 만약 이 path가 해당 위치에 없으면 자동으로 생성
```
- PVC/PV
  - PV 만든 후 PVC를 만들면 맞는 PV와 연결되게 되는데 한번 클레임이 연결되면 이 클레임은 다른 곳에서 사용할 수 없다.
  - 만약 PVC 생성했을 때 맞는 PV가 없을 경우 연결이 되지 않는다.(PVC가 요청한 볼륨이 낮으면 할당을 하주지만 더 높으면 할당해주지 않는다.)
```
# PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-03
spec:
  capacity: # 이렇게 적는다고 해서 local 볼륨이 이렇게 생성되지는 않는다.
    storage: 2G
  accessModes:
  - ReadWriteOnce # ReadOnlyMany
  local:
    path: /node-v
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [k8s-node1]} # node1에 만들어 진다.

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
      storage: 2G
  storageClassName: ""

#Pod
apiVersion: v1
kind: Pod
metadata:
  name: pod-volume-3
spec:
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: pvc-pv
      mountPath: /mount3
  volumes:
  - name : pvc-pv
    persistentVolumeClaim:
      claimName: pvc-01
```

### ConfigMap, Secret - Env, Mount
- ConfigMap: 내가 분리해야하는 일반적인 상수를 모아서 만든 것이다.
- Secret: 보안적인 부분을 모아서 만든 것이다.
- 파드 생성 시 두 오브젝트를 연결해서 만들어 파드의 환경변수에 오브젝트에 있는 상수들이 들어가게 된다.
- 방식
  <img>

  - Env (Literal): 상수를 넣는 방법
    - ConfigMap은 key와 value로 이루어져 있다. 그래서 필요한 상수들을 정의 해 놓으면 파드를 생성할 때 연결해서 컨터이너 안의 환경변수에 세팅할 수 있다. key, value를 무한히 넣을 수 있다.
    - Secret와 거의 동일 하지만 value를 넣을 때 base64 인코딩을 해서 넣는다. 파드로 연결할 때는 Decoding이 되서 들어간다. 일반적인 오브젝트 값들은 쿠버네티스 DB에 저장이되지만 Secret은 메모리에 저장이 되며 1Mbyte까지만 저장할 수 있다.
    <img>

  - Env (File)
    - ConfigMap: 파일 이름이 Key가 되고 파일 내용이 value가 된다. 파드로 연결하는 것은 대시보드에서 지원하지 않기 때문에 커맨드를 이용해야 한다. 만약 파일이 수정된다면 Pod가 죽어서 다시 연결해 가져와야 수정이 된다.
    - Secret은 ConfigMap과 거의 같지만 value가 base64로 인코딩 된다. 명령어를 사용할 대 파일 텍스트의 내용이 base64로 변경이 되기 때문에 파일 안의 내용이 base64였다면 두변 인코딩이 되는 것이기 때문에 주의해야 한다.
    <img>

  - Volume Mount (File)
    - ConfigMap: 파일을 파드에 담을 때 컨테이너 안에 mount path를 정의를 하고 paht 안으로 파일을 마운트 할 수 있다. 파일의 내용이 바뀌어도 마운트 된 것이기 때문에 바로 수정이 반영된다.

  ### ConfigMap, Secret - Env, Mount 실습
  - Env(literal)
    - Pod까지 생성 후 pod에 들어가 `cat /usr/bin/env`를 해보면 잘 들어가 있는 것을 다시 한 번 더 확인할 수 있다.
  ```
  # ConfigMap
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: cm-dev
  data:
    SSH: 'false' # '를 뺴고 넣으면 에러가 난다. 꼭 스트링 값만 지원한다.
    User: dev

  #Secret
  apiVersion: v1
  kind: Secret
  metadata:
    name: sec-dev
  data:
    Key: MTIzNA== # base64 인코딩을 하고 넣어줘야 에러가 나지 않는다.

  #Pod
  apiVersion: v1
  kind: Pod
  metadata:
    name: pod-1
  spec:
    containers:
    - name: container
      image: kubetm/init
      envFrom:
      - configMapRef:
          name: cm-dev
      - secretRef:
          name: sec-dev
  ```
  - Env(file)
    - master에서 ConfigMap, Secret 커맨드를 쳐서 생성한다. 생성 후 대시보드를 들어가 확인해 볼 수 있다.
    - Pod를 생성한 후 `env`로 들어가서 보면 ConfigMap Secret이 잘 연결 된 것을 확인할 수 있다.
  ```
  #ConfigMap
  echo "Content" >> file-c.txt
  kubectl create configmap cm-file --from-file=./file-c.txt

  #Secret
  echo "Content" >> file-s.txt
  kubectl create secret generic sec-file --from-file=./file-s.txt

  #Pod
  apiVersion: v1
  kind: Pod
  metadata:
    name: pod-file
  spec:
    containers:
    - name: container
      image: kubetm/init
      env:
      - name: file-c
        valueFrom:
          configMapKeyRef:
            name: cm-file
            key: file-c.txt
      - name: file-s
        valueFrom:
          secretKeyRef:
            name: sec-file
            key: file-s.txt

  ```
-  Volume Mount (File)
  - Pod 생성 후 컨테이너로 들어가 마운트 파일에 가보면 잘 연결된 것을 확인할 수 있고 수정 사항도 잘 반영되는 것을 알 수 있다.
```
#Pod
apiVersion: v1
kind: Pod
metadata:
  name: pod-mount
spec:
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: file-volume
      mountPath: /mount
  volumes:
  - name: file-volume
    configMap:
      name: cm-file
```

### Namespace, ResourceQuota, LimitRange
- 자원이 정해져 있는데 한 네임 스페이스에서 자원을 다 써버리면 다른 네임스페이스에서 자원을 사용할 수 있는 문제가 발생하는데 이러한 문제를 해결하기 위해 사용하는 것이 Resource quota이다. 이것을 네임 스페이스마다 달면 한계를 설정할 수 있어 파드 자원이 한계를 넘을 수 없다. 만약 한 파드가 자원 사용량을 너무 크게 해버리면 다른 파드들이 네임 스페이스에 더이상 들어올 수 없게 되고 이러지 못 하게 관리를 하기 위해서 Limit Range를 둬서 네임 스페이스에 들어오는 파드의 크기를 제한할 수 있다. 그리고 이것들은 클러스터에서 달 수 있어 제한을 걸 수 있다.
<img>

- Namespace
  - 한 네임스페이스 안에는 같은 타입의 오브젝트는 이름이 중복 될 수 없다
  - 타 네임스페이스에 있는 자원과 분리가 되서 관리가 된다. (라벨로 연결은 안된다)
  - NOde, PV는 모든 네임스페이스에서 공유할 수 있는 오브젝트이다.
  - 네임스페이스를 지우면 네임스페이스에 있던 자원이 지워진다.

<img>
- ResourceQuota
  - 설정하고 싶은 자원을 명시를 해서 달 수가 있다.
  - 스펙을 적지 않고 오브젝트를 생성하려고 한다면 생성이 되지 않는다.

<img>
- LimitRange
  - 네임 스페이스에 들어올 수 있는지 체크를 한다.

### Namespace, ResourceQuota, LimitRange 실습
- Namespace 
  - nm1와 nm2에 모두 서비스와 파드 생성 후 nm2의 파드 안 컨테이너에 들어가 `curl 20.111.218.77:8080/hostname` `curl 10.110.221.16:9000/hostname`
```
#Namespace-1
apiVersion: v1
kind: Namespace
metadata:
  name: nm-1

#Pod -1 -  20.111.218.77 
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  namespace: nm-1 #대시보드에서 이 네임스페이스를 지정을 하고 만들면 적지 않아도 저절도 해당 네임스페이스에 생성이 된다.
  labels:
    app: pod
spec:
  containers:
  - name: container
    image: kubetm/app
    ports:
    - containerPort: 8080

#Service-1 - 10.110.221.16
apiVersion: v1
kind: Service
metadata:
  name: svc-1
  namespace: nm-1
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080

#Pod -2
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  namespace: nm-2
  labels:
    app: pod
spec:
  containers:
  - name: container
    image: kubetm/init
    ports:
    - containerPort: 8080

#Service -2 
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  ports:
  - port: 9000
    targetPort: 8080
    nodePort: 30000 # 한 네임스페이스에서 30000을 쓰면 다른 네임스페이스에서 오브젝트는 이것을 사용할 수 없다.
  type: NodePort

#Pod -3
apiVersion: v1
kind: Pod
metadata:
 name: pod-2
spec:
  nodeSelector:
    kubernetes.io/hostname: k8s-node1
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: host-path
      mountPath: /mount1 # 한 네임스페이스에서 해당 파일에 마운트하면 다른 네임스페이스에서 똑같은 곳에 하게 되면 공유하게 되서 분리를 할 수 있는 명령어를 따로 실행해야 한다.
  volumes:
  - name : host-path
    hostPath:
      path: /node-v
      type: DirectoryOrCreate
```
- ResourceQuota
  - ResourceQuota가 잘 만들어 졌는지 `kubectl describe resourcequotas --namespace=nm-3` 커맨드를 master에 실행해 확인해 볼 수 있다.
  - 만약 네임스페이스에 리소스쿼터를 마지막에 만들면 제한을 넘게 되어도 그냥 잘 만들어 진다. 그래서 리소스 쿼터를 만들기 전에는 파드가 없는 상태에서 만들어야 한다.
```
#Namespcae
apiVersion: v1
kind: Namespace
metadata:
  name: nm-3

#ResourceQuota
apiVersion: v1
kind: ResourceQuota
metadata:
  name: rq-1
  namespace: nm-3
spec:
  hard:
    pods: 2 # 파드 갯수 제어
    requests.memory: 1Gi
    limits.memory: 1Gi

#Pod-1 -> 만드시 resources 부분을 명시해야한다는 에러가 뜬다.
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
spec:
  containers:
  - name: container
    image: kubetm/app

#Pod-2
apiVersion: v1
kind: Pod
metadata:
  name: pod-3
spec:
  containers:
  - name: container
    image: kubetm/app
    resources:
      requests:
        memory: 0.5Gi # 제한 자원량이 넘으면 에러가 뜬다.
      limits:
        memory: 0.5Gi
```
- LimitRange
  - LimitRange는 대시보드에서 확인이 안되기 때문에 master에서  `kubectl describe limitranges --namespace=nm-5` 커맨드를 이용해 확인할 수 있다.
  - 만약 한 네임스페이스에 LimitRange가 2개라면 max는 더 적은거에 min은 더 큰거에 맞춰진다.
  - 
```
#Namespcae
apiVersion: v1
kind: Namespace
metadata:
  name: nm-5

#LimitRange
apiVersion: v1
kind: LimitRange
metadata:
  name: lr-1
spec:
  limits:
  - type: Container
    min:
      memory: 0.1Gi
    max:
      memory: 0.4Gi
    maxLimitRequestRatio:
      memory: 3 # N 배 이상 차이가 나면 안된다.
    defaultRequest:
      memory: 0.1Gi
    default:
      memory: 0.2Gi

#Pod-1
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
spec:
  containers:
  - name: container
    image: kubetm/app
    resources:
      requests:
        memory: 0.1Gi
      limits:
        memory: 0.5Gi
```