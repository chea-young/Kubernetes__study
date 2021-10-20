### Pod - Lifecycle
- 파드의 라이프사이클: Pending - Running - Suceeded -Failed
    - Pending: 파드의 최초 상태
        - ReadinessProbe
        - Policy
    - Running
        - LivenessProbe
        - Qos
    - Succeeded
        - Policy
    - Failed
        - Policy
- 파드 생성 후 내용 하단을 보면 status가 존재한다.
    - 구조
    <img />
    #### Pod
    -  Status
        - Phase: 파드의 전제 상태를 대표하는 속성 [Pending, Running, Succeeded, Failed, Unknown]
        - Conditions: 파드가 생성되면서 실행하는 단계들이 있는데 그 단계와 상태를 알려주는 것이다. [Initialized, ContainerReady, PodScheduled, Ready]
            - False인 경우 False인 이유를 알아야 되기 때문에 Reason이 존재한다.
        - Reason: Conditions의 세부내용을 알려준다.[ContainersNotReady, PodCompleted]
            - ContainersNotReady: 컨테이너 작업이 아직 진행 중이다.
            - PodCompleted
    #### Containers
    -  Status
        - Phase - [Wating, Running, Terminated]
        - Reason - [ContainerCreating CrashLoopBackOff, Error, Completed]
#### Pending
- 파드의 최초 상태이다.
- Pending 중에 바로 Failed 혹은 Unknown(통신장애로 인하여)으로 빠질 수도 있다.
- 
<img />

- Wating(Reason: ContainerCreaing)
    - `Initialized: True`: initContainer - 본 컨테이너가 기동되기 전에 초기화시켜야 되는 내용이 있을 경우 그 내용을 담는 컨테이너를 만드는 항목이다.
    - `PodScheduled: True`: Node Schediling - 파드가 어느 노드에 올라갈 지 직접 지정하였을 때는 해당 노드에 혹은 자원 사용량을 판단해서 노드를 결정하는데 이것이 완료되었을 때이다.
    -  Image Downloading: 컨테이너의 이미지를 다운로드하는 동작이다.
#### Running
- 잡이나 크론잡으로 생성된 파드의 경우 자신의 일을 수행 중에는 러닝이지만 일을 맞치게 되면 Failed나 Succeeded로 바뀌게 된다.
- Running 중에 통신장애로 인하여 Unknown으로 빠질 수도 있다. 바로 해결이 되면 원래 상태로 돌아가지만 그것이 지속된다며 Failed가 된다.
<img />

- Wating(Reason: CrashLoopBackOff): 하나 또는 모든 컨테이너가 기동 중에 문제가 발생해서 재시작될 때이다.
    - `ContainerReady: False`
    - `Ready: False`
- 정상적으로 기동이 되었을 때이다.
    - `ContainerReady: True`
    - `Ready: True`
#### Failed
<img />

- 작업을 하고 있는 컨테이너 중에 하나라도 문제가 생겨서 에러가 되었을 때이다.
    - `ContainerReady: False`
    - `Ready: False`

#### Succeeded
<img />

- 컨테이너들이 모두 해당 일들을 다 맞쳤을 때이다.
    - `ContainerReady: False`
    - `Ready: False`

### Pod - ReadinessProbe, LivenessProbe
- 이 둘은 사용 목적은 다르지만 설정할 수 있는 것은 같다.
- 파드를 만들면 그 안에 컨테이너가 생기고 파드와 컨테이너 상태가 러닝이 되면서 그 안의 앱도 정상적으로 구동이 되고 서비스에 연결이 되고 그 서비스의 외부 IP를 통해서 사용자들이 실시간으로 접근을 하게 된다. (노드2, 파드2)그 상태에서 한 노드가 문제가 생기면 그 노드에 올라가 있던 파드도 Failed된다. 그러게 되면 한 파드에 트래픽이 집중되게 된다. 이제 오토힐링 기능을 통해서 파드는 재생성되고자 하고 파드와 컨테이너가 러닝상태이고 앱이 구동중인 상태에서 서비스와 연결이 된다. 사용자는 50퍼센트의 확률로 에러 페이지를 보게 된다. 이때 ReadinessProbe를 주게 되면 이러한 문제점을 해결할 수 있다.
    - ReadinessProbe: 앱 구동 순간에 트래픽 실패를 없앤다. (구동 중에는 파드를 서비스와 연결하지 않는다.)
- 파드와 컨테이너는 러닝인 상태에서 앱만이 다운이 되는 상황이 있는데 이때 앱의 장애 상황을 감지해주는 것이 LivenessProbe
    - LivenessProbe: App 장애 시 지속적인 트래픽 실패를 없앤다. 파드의 앱에 문제가 되면 파드를 restart하게 만들어준다.
- 속성
    - httpGet: [port, host, path, httpheader, scheme]를 체크할 수 있다.
    - Exec: [command]를 날려 특정 결과를 체크한다.
    - tcpSocket: [port, host]를 날려 성공여부를 확인한다.
- 옵션
    - initialDelaySeconds: 최초로 실행하기 전에 지연될 시간 간격이다.
    - periodSeconds: 프로브를 체크하는 시간의 간격이다.
    - timeoutSeconds: 지정된 시간까지 결과를 기다릴 시간이다.
    - successTreshols: 몇 번 성공 결과를 받아야 성공으로 인정할 횟수이다.
    - failureThreshold: 몇 번 실패 결과를 받아야 실패로 인정할지 결정하는 횟수이다.


### Pod - ReadinessProbe, LivenessProbe 실습
