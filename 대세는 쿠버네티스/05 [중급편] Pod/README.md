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
