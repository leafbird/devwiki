# swap in linux

## swap 상태를 확인하는 여러가지 방법들

```bash
swapon --show
cat /proc/swaps
cat /etc/fstab | grep swap
free -h
```

## swap을 비활성화하기

k8s 설치 시 swap을 비활성화해야 한다. 

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab # swap이 파티션일 경우
sudo sed -i '/swap.img/ s/^\(.*\)$/#\1/g' /etc/fstab # swap이 파일일 경우
```

## swap을 새로 만들고 설정하기

```bash
# 1. swap 파일 만들기
sudo fallocate -l 2G /swapfile
# 또는 dd 사용
# sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# 2. 권한 설정
sudo chmod 600 /swapfile

# 3. 스왑 영역으로 만들기
sudo mkswap /swapfile

# 4. 스왑 활성화
sudo swapon /swapfile

# 5. 부팅 시 자동 적용하려면 /etc/fstab에 추가
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```