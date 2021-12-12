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
              - 사전에 어떤 오브젝트가 미리 만들어져있고 그 오브젝트들에 여러 라벨들이 붙여있을 때 내가 원하는 오브젝트를 세밀하게 선택하기 위해서 보통 사용된다.(그래서 자주 사용하지는 않는다)
        <img />

        - operator
            - Exists: 자신이 키를 정하고 그에 맞는 값을 갖지고 있는 파드들을 연결을 한다.
            - DoesNotExist: 자신의 키의 값을 정하면 자신과 같지 않은 값을 가지고 있는 파드들과 연결을 한다.
            - In: key, value 지정이 가능해서 그와 관련되이 되어 있는 파드들과 연결이 가능하다.
            - Notln: key, value 지정이 가능해서 그와 관련이 없는 파드들과 연결이 가능하다.


### Replication Controller, ReplicaSet 실습
- Template
  - 파드와 레플리카스를 생성한 후 레플리카스에 들어가보면 파스가 연결되어 있는 것을 확인할 수 있다.
  - 레플리카스의 수를 하나 더 들리면 컨트롤러는 동일한 파드를 하나 더 생성한다.(해당 레플리카스 수는 유지되기 위해 자동적으로 생성하게 된다.)
  - 업그레이드를 하고 싶으면 레플리카스의 템플릿의 이미지의 버전을 바꾼 후 기존의 파드를 모두 삭제하면 바로 만들어지면서 다음 바꾼 버전으로 만들어진다.
  - 컨트롤러를 삭제하면 연결된 파드들은 함께 삭제 된다. (`kubectl delete replicationcontrollers replication1 --cascade=false` 이용하면 파드가 함께 제거되지 않는다.)
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
  terminationGracePeriodSeconds: 0 # Pod를 삭제하면 디폴트는 30초 후에 삭제하게 되어있는데 이것은 0초안에 바로 삭제하게 된다.

#ReplicationController
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica1
spec:
  replicas: 1 # CHECK 수를 들리면 자동으로 파드가 더 생성된다.
  selector:
    matchLabels:
      type: web # 파드 연결
  template: # 파드 내용 작성
    metadata: # 위의 파드 내용과 동일
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
  - 주의 사항
    - 셀렉터의 내용이 템플릿 라벨의 내용에 포함이 되어야 한다.
    - matchExpressions의 모든 조건들이 템플릿 라벨의 내용에 포함되어야 한다.
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
        ver: v1 #NOTE v3이 되면 셀렉터 내용과 맞지 않아 오류가 난다.
        location: dev
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 0

#Pod
apiVersion: v1
kind: Pod
metadata:
  name: pod-node-affinity1
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIngnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions: #좀 더 노드를 세밀하게 스케줄링하게 된다.
  	       - {key: AZ-01, operator: Exists}
  containers:
  - name: container
    image: kubetm/init
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
  - Deployment를 만드면 레플리카스만큼의 파드를 만든다. 
  - Deployment는 여러 레플리카셋을 만드는데 각각의 레플리카셋은 자신의 파드를 구별하기 위해서 추가적인 라벨과 셀렉터를 붙여준다.
  - 서비스를 만들면 아까 생성한 파드가 연결되어 있고 master에서 `curl [서비스 클러스터 IP]:8080/version`를 실행해 보면 파드의 버전을 리턴한다.
  - `while true; do [서비스 클러스터 IP]:8080/version; sleep 1; done`이걸 실행하여 1초마다 버전을 찍히게 해서 Deployment에서 이미지를 버전을 바꾸고 업데이트를 하면 '서비스에 접속할 수 없다라고 나오다가 바뀐 버전을 리턴한다. 그리고 대시보드의 파드에 가보면 새로운 버전의 파드가 하나씩 생성되어 다시 레플리카스의 수만큼 만들어진다.
    - 이 과정을 한번 더 하면(v3으로 업데이트하면) `revisionHistoryLimit: 1` 이기 때문에 레플리카셋의 v1은 삭제되면 v2와 v3가 남게 된다.
  - rollback을 하기 위해 대시보드에서 Deployment의 이미지를 이전 버전으로 바꿀 수 있고 `kubectl rollout undo deployment deployment-1 --to-revision=2`, `kubectl rollout history deployment deployment-1` 이렇게 커맨드를 이용해서 바꿀 수도 있다.
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
  - `while true; do [서비스 클러스터 IP]:8080/version; sleep 1; done`를 mater에 실행시킨 상태에서 Deployment를 다음 바전으로 변경해보면 Recreate가 다르게 완전 업그레이드가 되기 전까지 v1, v2가 번갈아서 리턴되며 완전이 업그레이드가 끝났을 때 v2만이 계속 출력된다.
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
- Blue/Green
 -v1과 v2에대한 레플리카셋과 서비스를 만든 후 v1으로 서비스가 되고 있는 상태에서 `while true; do [서비스 클러스터 IP]:8080/version; sleep 1; done`를 mater에서 실행시킨 뒤에 서비스이 셀렉터를 v2를 변경하면 Downtime 없이 v1에서 바로 v2로 반환되는 것을 확인할 수 있다.
```
#ReplicaSet
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica1
spec:
  replicas: 2
  selector:
    matchLabels:
      ver: v1
  template:
    metadata:
      name: pod1
      labels:
        ver: v1
    spec:
      containers:
      - name: container
        image: kubetm/app:v1
      terminationGracePeriodSeconds: 0

#Service
apiVersion: v1
kind: Service
metadata:
  name: svc-3
spec:
  selector:
    ver: v1
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
```

### DaemonSet, Job, CronJob
- Controller
  - Deamonset
  <img />

    - Node들이 있고 각 노드에 다른 자원들이 들어간 상태에서 각각의 노드마다 설치해서 쿠버네틱스 자체가 네트워킹을 관리하기 위해서 각각의 노드에 데몬셋으로 프록시 역할을 하는 파드를 생성한다.
      - 이렇게 각각 존재해야하는 서비스는 Prometheus[Performance](각 노드들의 성능상태를 감시), Logging[fluentd](특정 노드에 문제가 발생했을 경우 바로 파악하기 위해 사용), GlusterFS[Storage](각각의 노드에 설치되서 해당 자원을 가지고 네트워크 파일 시스템을 구축 )
  - Job, CronJob
  <img />

  - Pod들로 만들어진 파드는 문제 시 그냥 제거되지만 컨트롤러에 의해서 생성된 파드는 문제 시 다른 노드에 다시 재 생성된다. 그리고 오랫동안 사용하지 않은 파드들은 레플리카셋은 다시 재시작시켜준다.
    - recreate: 아이피, 이름이 달라진 채로 생성된다
    - restart: 파드는 그대로 있고 파드안의 컨테이너만 재개봉시켜준다.
  - Job: 파드는 프로세서가 일을 하지 않으면 파드는 종료(자원을 사용하지 않는 상태로 멈춤)가 된다.
  - CronJob: Job들을 주기적은 시각에 따라서 생성을 한다. 보통 잡 단일로 사용하기 보다는 크론잡을 만들어 주기적으로 단위를 사용한다.
- DaemonSet
  <img />

  - 셀렉터와 템플릿이 있어서 모든 노드에 탬플릿으로 파드를 만들고 셀렉터와 라벨로 데몬셋과 연결이 된다.
  - nodeSelector: 라벨을 이것으로 지정하며 이게 없는 노드에는 파드가 생성되지 않는다.(데몬셋은 하나를 초과해서 파드를 만들 수는 없지만 아예 안만들 수는 있다.)
  - hostPort: 직접 노드에 있는 포트가 이 파드로 연결이 되서 외부에서 접근 할 수 있다.
- Job
  <img />

  - 템플릿과 셀렉터가 존재한다.
  - 템플릿에는 특정 작업만 하고 종료가 되는 일을하는 파드들을 담는다. 
  - selector는 직접 만들지 않아도 잡이 알아서 만들어준다.
  - completions: 갯수에 따라 파드를 순차적으로 실행시켜서 작업이 끝나야 잡이 제가가 된다.
  - parallelism: 갯수에 따라 그 개수만큼의 파드가 생성이 된다.
  - activeDeadlineSeconds: 숫자만큼 기능이 종료되고 실행되고, 실행되지 못 한 파드들이 다 제가가 된다.

- CronJob
  <img />

  - Job 템플릿이 있어서 Job을 생성하고 스케줄이 있어서 그 시간을 주기로 잡을 만든다.
  - Allow: 1분마다 스케줄을 한다고 설정하며 1분이 됬을 때 잡이 만들어지고 크론잡이 만들어진다.
  - Forbid: 
  - Replace: 

### DaemonSet, Job, CronJob 실습
- DaemonSet
  - HostPort 기능 확인하기
    - 데몬셋을 만들면 각각의 노드에 파드가 만들어진다.
    - master에 `curl [노드 1,2 의 IP]:18080/hostname`쳐보면 각자 node에 대한 파드 이름이 나오는 것을 확인할 수 있다.
  - NodeSelector 기능 확인하기
    - 우선 각가의 노드에 `kubectl label nodes k8s-node1 os=centos`, `kubectl label nodes k8s-node2 os=ubuntu` 커맨드를 실행시켜 라벨을 달고 데몬셋을 만들고  `nodeSelector`에 대한 노드에만 파드가 생성된다.
```
#DaemonSet - Hostport
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemonset-1
spec:
  selector:
    matchLabels:
      type: app
  template: # 파드의 내용이 들어감.
    metadata:
      labels:
        type: app
    spec:
      containers:
      - name: container
        image: kubetm/app
        ports:
        - containerPort: 8080
          hostPort: 18080 # 이 포트로 들어오면 해당 노드에 생성된 파드로 트래픽이 가는 것을 볼 수 있다.

#DaemonSet - NodeSelector
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemonset-2
spec:
  selector:
    matchLabels:
      type: app
  template:
    metadata:
      labels:
        type: app
    spec:
      nodeSelector: #지정된 노드에만 파드가 생성된다.
        os: centos
      containers:
      - name: container
        image: kubetm/app
        ports:
        - containerPort: 8080
```
- Job
  - 1: 로그를 보면 job start를 찍고 파드는 계속 Runnig 중이다가 20초가 지나면 Terminate 상태가 되면서 파드가 종료가 된다. 그 후 job의 로그를 보면 job end가 찍힌 것을 확인할 수 있다. 이 후 job을 삭제하면 연결된 pod도 함께 삭제가 된다.
  - 2: 돌아가다가 잡이 지정된 시간보다 오래활성화가 되었다고 오류가 되고 처음에 실행되었던 2파드만이 정상적으로 종료가 되었고 그 다음에 만들어진 2개의 파드는 삭제가 되고 총 6개를 준비를 했지만 잡이 중지가 됬기때문에 더 이상 파드는 생기지 않고 잡의 기능이 멈춘다.
```
#Job-1
apiVersion: batch/v1
kind: Job
metadata:
  name: job-1
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: container
        image: kubetm/init
        command: ["sh", "-c", "echo 'job start';sleep 20; echo 'job end'"] #job end가 나오면 해당 job의 역할도 끝난다.
      terminationGracePeriodSeconds: 0

#Job-2
apiVersion: batch/v1
kind: Job
metadata:
  name: job-2
spec:
  completions: 6 # 하나의 잡에 대해 6개의 파드를 준비한다.
  parallelism: 2 # 2의 파드씩 paral하게 된다.
  activeDeadlineSeconds: 30 #30초씩 잡은 중지되면서 현재 동작 중이던 파드들은 삭제가 된다.
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: container
        image: kubetm/init
        command: ["sh", "-c", "echo 'job start';sleep 20; echo 'job end'"]
      terminationGracePeriodSeconds: 0
```

- CronJob
  - 1
    - CronJob의 트리거로 바로 잡을 생성할 수 있다.
    - `kubectl create job --from=cronjob/cron-job cron-job-manual-001`의 커맨드로 크론잡에서 이름이 cron-job인 크론잡에서 가져와 잡을 cron-job-manual-001 이름으로 생성하게 된다.
      - 이렇게 만들게 되면 크론잡을 삭제해서 잡은 삭제가 되지 않는다.
    - 크론잡이 Suspend가 false에서 true가 되면 일시적으로 잡을 만들지 않는다.(true가 되게 대시보드의 yaml을 수정해서 바꿀 수 있다.)
      - `kubectl patch cronjobs cron-job -p '{"spec" : {"suspend" : false }}'` 이렇게 커맨드로도 바꿀 수 있다.
  - ConcurrencyPolicy 
    - Forbid: 2분 20초 동안 Sleep을 하기 때문에 20은 만들어주지만 21분때는 스킵되고 22분 때에 20분꺼가 끝나면서 만들어질 것이다.
    - Replace: 20분 스케줄에 잡이 하나 만들어져서 파드가 Running 중이다가 21분 때 파드가 러닝 중이기 때문에 잡은 생성되지 않고 22분때에 새로운 잡이 생기면서 30분때의 파드와 연결이 되서 계속 Running이 되어 있을 것이다.
      - 
```
#CronJob -1
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cron-job
spec:
  schedule: "*/1 * * * *" #잡을 1분에 하나씩 생성
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: container
            image: kubetm/init
            command: ["sh", "-c", "echo 'job start';sleep 20; echo 'job end'"] #CHECK 이게 없으면 잡이 제거가 되지 않는다.
          terminationGracePeriodSeconds: 0

#CronJob - ConcurrencyPolicy - Forbid
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job-2
spec:
  schedule: "20,21,22 * * * *" #20,21,22분에 잡이 생성된다.
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: container
            image: kubetm/init
            command: ["sh", "-c", "echo 'job start';sleep 140; echo 'job end'"] 
          terminationGracePeriodSeconds: 0

#CronJob - ConcurrencyPolicy - Replace
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job-2
spec:
  schedule: "20,21,22 * * * *" 
  concurrencyPolicy: Replace
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: container
            image: kubetm/init
            command: ["sh", "-c", "echo 'job start';sleep 140; echo 'job end'"] 
          terminationGracePeriodSeconds: 0
```
