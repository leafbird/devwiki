사내 여유장비 `ST-BuildWatch`에 k8s 첫 설치한 과정 기록

# 단일 머신에 k8s 설치 (Control Plane + Worker Node)

### Swap 비활성화

swap은 파티션으로 되어있을수도 있고, 파일로 되어있을수도 있다. 
우분투는 swap을 파일로 설정하는 것 같다. 파일일 때는 검출 방식이 다름.
미리 `bat /etc/fstab`으로 확인해보자.

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab # swap이 파티션일 경우
sudo sed -i '/swap.img/ s/^\(.*\)$/#\1/g' /etc/fstab # swap이 파일일 경우
```

### 필요한 패키지 설치

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

### 컨테이너 런타임 설치. 버전 매칭이 중요. 

containerd를 설치하는 과정이 있는데, 나는 기존에 docker가 설치되어 있어 이미 깔려있었기 때문에 생략했다. 
하지만 제대로 연결되지 않아 결국 다시 설치함.

### kubeadm, kubelet, kubectl 설치

여기는 k8s의 버전에 따라 많이 달라지는 듯 하다. 공식 문서의 안내를 따라 진행했다.
link : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
```

### 설치 오류 발생. 보류상태가 된 패키시는 자동 설치하지 않음. 

```
E: 보유 패키지가 변경되었으며 --allow-change-held-packages 옵션 없이 -y옵션이 사용되었습니다.
```

```bash
dpkg --get-selections | grep hold # 보류상태인 패키지 확인
sudo apt-mark unhold kubeadm kubelet kubectl # 보류상태 해제
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl # 보류상태 해제 후 다시 설치
sudo apt-mark hold kubelet kubeadm kubectl # 다시 보류상태로 변경
```

### 설치 오류 발생. kubeadm init ... 할 때 containerd에 연결 실패

```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
[init] Using Kubernetes version: v1.32.3
[preflight] Running pre-flight checks
W0406 09:50:05.031460  441165 checks.go:1077] [preflight] WARNING: Couldn't create the interface used for talking to the container runtime: failed to create new CRI runtime service: validate service connection: validate CRI v1 runtime API for endpoint "unix:///var/run/containerd/containerd.sock": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
error execution phase preflight: [preflight] Some fatal errors occurred:
failed to create new CRI runtime service: validate service connection: validate CRI v1 runtime API for endpoint "unix:///var/run/containerd/containerd.sock": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService[preflight] If you know what you are doing, you can make a check non-fatal with --ignore-preflight-errors=...
To see the stack trace of this error execute with --v=5 or higher

이 에러는 containerd의 gRPC 인터페이스(CRI) 중에서 Kubernetes가 기대하는 runtime.v1 API가 활성화되지 않아서 발생하는 문제입니다.
즉, kubeadm이 containerd에 연결하려고 하는데, 기대하는 방식대로 작동하지 않아서 Kubernetes가 컨테이너 런타임으로 인식하지 못하는 거예요.
```

gpt가 처음에 알려줬을 때 건너뛰었던 containerd 설치를 진행.

```bash
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### kubeadm으로 클러스터 초기화

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 # --pod-network-cidr는 flannel을 사용할 때 필요
```

### kubeconfig 설정

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### pod network 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 현재 머신을 워커 노드로 추가

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### 문제 발생. 기존에 설치했던 docker가 실행되지 않음. 

내 경우에서는 docker 데몬이 아예 사라져 있었다. 재설치를 진행해 해결했다.

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker --now
```

# k9s 설치
k9s는 k8s 클러스터를 관리하기 위한 CLI 툴이다. 
link : https://github.com/derailed/k9s

페이지에서 안내하는 명령은 권한지 없어 제대로 실행되지 않는다. 
나는 2개 명령만 sudo 넣거 실행했는데, 다음에 설치한다면 3개 명령 모두 sudo 넣고 실행해볼 것. 

```bash
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb # 제대로 실행되지 않음.

sudo wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && sudo apt install ./k9s_linux_amd64.deb && sudo rm k9s_linux_amd64.deb # 각 명령 앞에 sudo 넣어 실행
```

# 이후에 머신을 추가하여 컨트롤러와 노드를 분리하기

1. 워커노드에서 위와 동일한 사전 설정 진행 (swap off, container runtime, kubeadm 등)
2. 기존 클러스터에서 join 명령어를 확인하여 워커노드에 붙이기

```bash
kubeadm token create --print-join-command
```

예시 출력:

```bash
kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:...
```

3. join 명령어를 복사하여 워커노드에서 실행

```bash 
sudo kubeadm join ... # 출력된 명령어
```

# 컨트롤 플레인 노드 추가

기존 컨트롤러를 복제하거나 HA 구성을 위해 컨트롤 플레인을 여러 대로 확장하고 싶을 경우:

마스터에서:

```bash
kubeadm init phase upload-certs --upload-certs
```

출력된 `--certificate-key`를 복사하여 새로운 컨트롤 플레인 노드에서 사용.

```bash
kubeadm join 192.168.1.100:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:... \
  --control-plane --certificate-key <CERTIFICATE_KEY>
```

