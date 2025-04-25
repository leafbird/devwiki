# k8s Port 유형 정리

NodePort
- 외부에서 접속하기 위해 사용하는 포트
Port
- Cluster 내부에서 사용할 Service 객체의 포트
TargetPort
- Service 객체로 전달된 요청을 Pod(deployment)로 전달할 때 사용하는 포트

전체 서비스 흐름으로 보면 `NodePort` -> `Port` -> `TargetPort` 순서로 전달된다.

Q1. 같은 클러스에서 서로다른 namespace에 동일한 port를 가진 service가 존재할 수 있는가?
- 네, 서로 다른 namespace에 동일한 port를 가진 service가 존재할 수 있다. 하지만 같은 namespace에 동일한 port를 가진 service는 존재할 수 없다.

```yaml
services:
  clientListen:
    name: "client-listen"
    type: NodePort
    ports:
      - name: client-listen-port
        protocol: TCP
        port: 9300
        targetPort: 9300
        nodePort: 30300
```

위에서 정의한 nodeport를 서로다른 namespace로 배포하는 경우, port와 targetPort는 변경할 필요 없다. 하지만 nodePort는 변경해야 한다. nodePort는 클러스터의 모든 노드에서 고유해야 하기 때문이다.