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