# install nginx

참고 : https://cpdev.tistory.com/243

```
# nginx 설치
sudo dnf update -y
sudo dnf install -y nginx
nginx -v
```

```
# 서비스 설정
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

```
# 방화벽 설정
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

sudo firewall-cmd --list-all
```

```
# nginx 설정 파일
sudo vi /etc/nginx/nginx.conf

# 또는 개별 사이트 설정을 /etc/nginx/conf.d/default.conf에서 관리할 수도 있습니다.
sudo vi /etc/nginx/conf.d/default.conf

# 변경 후 설정 파일에 오류가 없는지 확인:
sudo nginx -t

# 이상이 없다면 Nginx를 다시 로드합니다.
sudo systemctl restart nginx
```

# nvim 직접 빌드

기본적으로 [proxmox 초기 세팅](../OS-linux/Proxmox/proxmox%20초기세팅.md)에 정리된 진행을 따른다. 

빌드를 하기 위한 툴 설치가 ubuntu와 다르므로 아래 사항을 참고한다.

```
# 전체 설치
sudo dnf groupinstall "Development Tools" -y

# 최소 설치
sudo dnf install gcc gcc-c++ make cmake3

# 설치 확인
gcc --version
g++ --version
```