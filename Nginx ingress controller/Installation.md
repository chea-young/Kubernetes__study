kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml 
# {DOMAIN}:{INGRESS_CONTROLLER_PORT} 로 서비스가 노출


https://5equal0.tistory.com/entry/Kubernetes-Nginx-Ingress-Controller


apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    app.kubernetes.io/component: controller
  name: nginx
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: k8s.io/ingress-nginx












apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-test
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: web-svc
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific

