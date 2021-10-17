## Controller
- 서비스를 관리하고 운영하는데 도움을 준다.
#### 핵심 기능
- Auto Healing: 파드가 노드위에 올려져있는데 노드에 문제가 생기면 서비스에 문제가 나타나기 때문에 즉각적으로 인식하고 다른 노드위에 파드를 생성시킨다. 혹은 파드에 문제가 생겨도 즉각적으로 문제를 해결한다.
- Software Update: 여러 파드에 대한 버전을 업그레이드 해야될 경우 컨트롤러를 통해서 한번에 쉽게 할 수가 있다. 업그레이드 도중 문제가 생기면 rollback을 할 수 있는 기능도 제공을 한다.
- Auto Scaling : 파드의 자원이 limited 상태가 되었을 때 상태를 파악하고 파드를 하나 더 만들어 줌으로써 자원을 분산시켜지고 성능의 저하없이 안정적인 서비스를 제공할 수 있다.
- Job: 일시적인 작업을 해야할 경우 필요한 순간에만 파드를 만들어서 해당 작업을 이행하고 삭제를 한다.

### Replication Controller, ReplicaSet
- 현재는 Replication Controller를 대체해서 ReplicaSet로 사용하고 있다.
- 컨트롤러와 파드는 라벨과 셀렉터로 연결이 된다.
- ReplicaSet
    - Template
        <img />

        - 파드가 죽으면 ReplicaSet에 있던 템플릿으로 파드를 재생성시켜 준다.
        - 이 템플릿으로 v2에 대한 버전을 올리고 싶을 때 생성을 하고 기존에 있던 파드를 제거하여서 버전 업그레이드를 수동으로 할 수가 있다.
    - Replicas
        <img />

        - 'replicas' 의 개수만큼의 파드만이 관리가 된다. 만약 이것이 3개라면 하나만 만들어도 3개로 들어나 scale out이 된다.
        - 만약 파드가 삭제되면 relicas 개수만큼 파드를 생성한다.
        - 컨트롤러 만으로 replicas와 template을 이용해 파드를 생성할 수 있다.
    - Selector(ReplicaSet에만 있는 기능)
        <img />

        - key, value가 모두 같은 파드들과만 연결을 한다.
        - 추가적인 기능
            - matchLabels: Replication과 같이 key, value가 모두 같아야 연결을 해준다.
            - matchExpressions: key와 value를 자세하게 컨트롤 할 수 있다. 만약 operator를 Exist라고 넣게 되면 kery에 대해서 라벨이 같은 모든 파드들을 선택하게 된다.
        <img />

        - operator
            - Exists: 자신이 키를 정하고 그에 맞는 값을 갖지고 있는 파드들을 연결을 한다.
            - DoesNotExist: 자신의 키의 값을 정하면 자신과 같지 않은 값을 가지고 있는 파드들과 연결을 한다.
            - In: key, value 지정이 가능해서 그와 관련되이 되어 있는 파드들과 연결이 가능하다.
            - Notln: key, value 지정이 가능해서 그와 관련이 없는 파드들과 연결이 가능하다.


### Replication Controller, ReplicaSet 실습
- Template
```
#Pod
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    type: web
spec:
  containers:
  - name: container
    image: kubetm/app:v1
  terminationGracePeriodSeconds: 0

#ReplicationController
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica1
spec:
  replicas: 1
  selector:
    matchLabels:
      type: web # 파드 연결
  template: # 파드 내용 작성
    metadata:
      name: pod1
      labels:
        type: web
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 0
```
- Selector
```
#Selector
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica1
spec:
  replicas: 1
  selector:
    matchLabels:
      type: web
      ver: v1
    matchExpressions: # 상세한 설정이 들어간다.
    - {key: type, operator: In, values: [web]}
    - {key: ver, operator: Exists}
  template:
    metadata:
      labels:
        type: web
        ver: v1
        location: dev
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 0

```

### Deployment - Recreate, RollingUpdate
- Deployment: 현재 한 서비스가 운영 중인데 서비스를 업데이트를 해야해서 도움을 주는 컨트롤러이다.
- Ingress Controller: 유입되는 트래픽을 URL path에 따라서 서비스에 연결해주는 역할을 한다.
#### 핵심기능
<img />

  - **ReCreate**
<img />

  - 버전 업그레이드를 한다고 가정하였을 때 우선 파드들을 삭제하면 서비스에 대한 downtime이 발생하고 자원사용량이 없어지게 된다. 그 후 다음 버전에 대한 파드를 만들어진다.
  - 문제점: downtime 때문에 일시적인 정지가 일어날 수 있다.
  - 배포방식:  Deployment에 selector replicas, template는 ReplicaSet을 만들어 그것으로 파드를 관리하기 위해 값을 넣어준다. 업그레이드를 하고 싶다면 Deployment의 템플릿을 다음버전으로 바꿔주고 기존의 ReplicaSet의 replicas를 0으로 만들어주면 파드들도 없어지고 서비스도 연결대상이 없어지기 때문에 Downtime이 발생한다. 이후 새로운 ReplicaSet을 만들어 다음 버전에 대한 파드를 만들어 서비스와 연결된다. 새로만든 replicas를 늘리고 이전에 레플리카셋의 replicas를 하나 제거하고 이 과정을 반복해서 업그레이드를 시킨다.
- **Rolling Update**
<img />

  - 버전 업그레이드를 한다고 가정하였을 때 다음 버전에 대한 파드를 생성하며 그렇기 때문에 자원 사용량이 늘어나게 된다. 이 후 전 버전 파드를 하나 삭제하고 이 방식을 반복한다.
  - 추가적인 자원을 요구하기는 하지면 downtime이 없는 방식이다.
  - 배포방식 : 업그레이드가 하고 싶다음 다음 버전으로 템플릿을 교체해 Replicaset을 만들어주고 그에대한 파드를 만들어 서비스와 연결시켜준다.
- Blue/Green

  - 컨트롤러로 파드를 생성하면 라벨이 있기때문에 서비스에 있는 셀렉터와 연결할 수 있다. 이 상태에서 컨트롤러를 하나 더 만들어서 다음 버전에 대한 파드를 만들어 자원사용량은 기존의 두 배가 되고 새로 만든 파드에만 서비스 연결을 해주게 된다.
  - 만약 새로 만든 버전이 문제가 생기게 되면 이전 버전으로 다시 연결할 수 있어 문제 시 rollback이 된다. (새로운 버전에 문제가 없으면 이전 버전은 삭제한다.)
- Canary

- (불특정다수에 대한 방식)파드에 라벨이 붙어있는 상태에서 서비스를 만들어 연결하는데 시범으로 컨트롤러를 만들어서 다음 버전에 대한 파드를 만들어 서비스에 연결한다. 만약에 문제가 되면 새로만든 컨트롤러의 replicas를 0으로 만든다.
- 이전 버전과 새로운 버전 대로 서비스를 만들고 Ingress Controller의 path를 버전으로 연결하면 해당 path로 연결하는 사람들은 새로운 버전에 대해서만 이용하게 된다.

### Deployment - Recreate, RollingUpdate 실습
- Recreate
```
# Service
apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  selector:
    type: app
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080

# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-1
spec: # 만들 때 3개를 만드는 것을 알 수 있다.
  selector: #CHECK
    matchLabels:
      type: app
  replicas: 2 #CHECK
  strategy: # 배포방법
    type: Recreate
  revisionHistoryLimit: 1  # 0인 래플리카셋을 하나 남기겠다 디폴트는 10개
  template: #CHECK 
    metadata: 
      labels:
        type: app
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 10
```
- RollingUpdate
```
# 서비스
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  selector:
    type: app2
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080

# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-2
spec:
  selector:
    matchLabels:
      type: app2
  replicas: 2
  strategy:
    type: RollingUpdate
  minReadySeconds: 10 #업데이트가 순식간에 진행되지 않고 10초라는 기간을 가지고 진행하게 된다.
  template:
    metadata:
      labels:
        type: app2
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 0
```