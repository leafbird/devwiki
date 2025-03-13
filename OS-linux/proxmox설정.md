## 새로운 사용자 추가

```sh
adduser florist # 사용자 추가
usermod -aG sudo florist # sudo 권한 부여

su - florist # 사용자 변경
sudo ls /root # 동작 테스트
```

## root의 shell을 변경할 때 오류나는 경우 

```sh
root@pve:~# chsh -s $(which zsh)
Password:
chsh: PAM: Authentication failure
root@pve:~#
```

이런 경우에는 `/etc/passwd` 파일을 수정해야 합니다. 

```sh
root@pve:~# nano /etc/passwd
```

## hostname 변경

3가지 파일을 수정해야 한다.

```sh
vi /etc/hostname # 1. 호스트 이름 변경
vi /etc/hosts # 2. 호스트 이름 변경
```

3. Proxmox는 `/etc/pve/local/` 경로에서 현재 노드 이름을 사용하므로, `노드 이름을 변경`해야 합니다.

```sh
mv /etc/pve/local/pve-ssl.key /etc/pve/local/proxmox-server-ssl.key
mv /etc/pve/local/pve-ssl.pem /etc/pve/local/proxmox-server-ssl.pem
mv /etc/pve/local/pve /etc/pve/local/proxmox-server
```

## 데비안 12에서 fastfetch 설치하기

```sh
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.17.2/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
sudo apt install -f # 의존성 해결
fastfetch
```

## neovim 버전 업그레이드 - 백포트 저장소 추가

```sh
#sudo vi /etc/apt/sources.list

deb http://deb.debian.org/debian bookworm-backports main
```

```sh
sudo apt update
sudo apt -t bookworm-backports install neovim # 설치
sudo apt -t bookworm-backports upgrade neovim # 업그레이드
```

## neovim 빌드

백포트에서 받아도 버전이 낮다... 그냥 빌드하자.

```sh
sudo apt install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install
```

note: fd는 설치하려면 `fd-find`로. eza는 간단히 되지 않는다. 문서 참고. https://github.com/eza-community/eza/blob/main/INSTALL.md

```sh
sudo apt update
sudo apt install -y gpg
# --

sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
```