# old desktop에 k3s 설치

```bash
curl -sfL https://get.k3s.io | sh - 
```

다른 옵션을 변경하지 않고 기본으로 설치. ssh로 붙어서 원격 설치했는데, 설치한 뒤로 접속이 끊기고 다시 붙지 못하는 현상 발생. 
localhost에서는 `kubectl get nodes` 명령이 정상 실행되었다. reboot 한 번 해준 후로 원격 접속이 가능해짐. 

설정을 로컬 경로로 가져와 kubectl을 sudo 없이 사용하도록 설정.
    
```bash
mkdir ~/.kube 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
# Test to make sure non-root kubectl is working
kubectl get nodes
```

# argocd 설치

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

k9s로 실행 상태를 확인후, 외부 접속하기 위해 svc 타입 변경. 문서에는 LoadBalancer로 변경하라고 되어있지만, external ip를 받을 수 없으므로 NodePort로 변경. 

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc -n argocd # 30000~32767 포트 중 하나로 변경됨
```

초기 비번 확인

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
```

argocd cli 설치 후, 초기 비번 변경하기

```bash
# argocd cli 설치
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

argocd login <ARGOCD_SERVER> --username admin --password <INITIAL_PASSWORD> --insecure

argocd account update-password
```