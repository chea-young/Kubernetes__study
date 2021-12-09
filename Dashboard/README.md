최신버전확인: https://kubernetes.io/ko/docs/tasks/access-application-cluster/web-ui-dashboard/

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
155 apiVersion: rbac.authorization.k8s.io/v1
156 kind: ClusterRoleBinding
157 metadata:
158   name: kubernetes-dashboard
159 roleRef:
160   apiGroup: rbac.authorization.k8s.io
161   kind: ClusterRole
162   name: cluster-admin                  <<<<<<<<<<<<<< 수정한 부분
163 subjects:
164   - kind: ServiceAccount

165  name: kubernetes-dashboard
166  namespace: kubernetes-dashboard
(...)
187  spec:
188    containers:
189      - name: kubernetes-dashboard
190        image: kubernetesui/dashboard:v2.3.1
191        imagePullPolicy: Always
192        ports:
193          - containerPort: 8443
194            protocol: TCP
195        args:
196          - --auto-generate-certificates
197          - --enable-skip-login                   <<<<<<<<<<<<<< 추가한 부분
198          - --namespace=kubernetes-dashboard
199          # Uncomment the following line to manually specify Kubernetes API server Host
200          # If not specified, Dashboard will attempt to auto discover the API server and connect
201          # to it. Uncomment only if the default does not work.
202          # - --apiserver-host=http://my-address:port



[root@master01 centos]# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
--2021-12-09 10:22:53--  https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.108.133, 185.199.110.133, 185.199.111.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.108.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7543 (7.4K) [text/plain]
Saving to: ‘recommended.yaml’

100%[===========================================================================================================================================================

2021-12-09 10:22:53 (8.06 MB/s) - ‘recommended.yaml’ saved [7543/7543]

[root@master01 centos]# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml^C
[root@master01 centos]# ls
kubernetes-dashboard-deployment.yml  recommended.yaml  test.yaml
[root@master01 centos]# vi recommended.yaml
[root@master01 centos]# kubectl apply -f recommended.yaml
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
[root@master01 centos]# nohup kubectl proxy --port=8001 --address=192.168.0.5 --accept-hosts='^*$' >/dev/null 2>&1 &
[2] 24079
[root@master01 centos]# kubectl get pod --all-namespaces
NAMESPACE              NAME                                         READY   STATUS    RESTARTS   AGE
default                echo-588c888c78-bnpfc                        1/1     Running   0          18h
kube-system            coredns-64897985d-bcr9h                      1/1     Running   0          20h
kube-system            coredns-64897985d-jcj2c                      1/1     Running   0          20h
kube-system            etcd-master01                                1/1     Running   0          20h
kube-system            kube-apiserver-master01                      1/1     Running   0          20h
kube-system            kube-controller-manager-master01             1/1     Running   0          20h
kube-system            kube-flannel-ds-ctcgc                        1/1     Running   0          20h
kube-system            kube-flannel-ds-f8rg9                        1/1     Running   0          20h
kube-system            kube-flannel-ds-l889r                        1/1     Running   0          18h
kube-system            kube-proxy-f45r2                             1/1     Running   0          20h
kube-system            kube-proxy-l2bdv                             1/1     Running   0          18h
kube-system            kube-proxy-lpw6l                             1/1     Running   0          20h
kube-system            kube-scheduler-master01                      1/1     Running   0          20h
kubernetes-dashboard   dashboard-metrics-scraper-799d786dbf-7vqvz   1/1     Running   0          11m
kubernetes-dashboard   kubernetes-dashboard-6477f4c44d-dnqzz        1/1     Running   0          11m
[2]+  Exit 1                  nohup kubectl proxy --port=8001 --address=192.168.0.5 --accept-hosts='^*$' > /dev/null 2>&1



