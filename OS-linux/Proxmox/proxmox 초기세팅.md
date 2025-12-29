# proxmox setting

## registry 설정

GUI에서 enterprise repository를 비활성화하고, community repository를 활성화한다. 

pbs인 경우 ui에서 설정이 안되므로, 터미널에서 직접 설정한다.

251229. pbs 4.x (trixie 계열)에서는 기존 방식이 동작하지 않아 grok이 알려준 아래 방법으로 처리

```sh
vi /etc/apt/sources.list.d/pbs-enterprise.sources
# 파일 끝에 다음 줄 추가
Enabled: false

# 새 파일 생성
cat > /etc/apt/sources.list.d/pbs-no-subscription.sources <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: trixie
Components: pbs-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

apt update
```

```sh
sudo vim /etc/apt/sources.list.d/pbs-enterprise.list

# deb https://enterprise.proxmox.com/debian/pbs bookworm pbs-enterprise # 주석처리
deb http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription # 추가

# ----
# gpg key 추가 (한 번만 실행)
wget -qO - https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg | sudo tee /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg > /dev/null
```

## 기본 설정은 우분투 서버 참고

기본적으로는 [ubuntu server 설정](./ubuntu server 설정.md)를 따라가면서 설치. 

* eza는 지금 리포지토리에 없기 때문에 제외하고 진행. 
* fastfetch 설치방법이 다름. 아래처럼 진행.

```bash
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.42.0/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
```

## 데비안 12에서 fastfetch 설치하기

```sh
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.17.2/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
sudo apt install -f # 의존성 해결
fastfetch
```

## nvim 직접 빌드

패키지 매니저에 설치된 버전이 너무 낮아 (v0.7.2) 직접 빌드하는 것이 좋다.
참고 : 
* https://github.com/neovim/neovim/blob/master/BUILD.md#build-prerequisites
* https://github.com/neovim/neovim/blob/master/BUILD.md

```
sudo apt-get install ninja-build gettext cmake curl build-essential
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

패키지로 받은 파일은 `/usr/bin/nvim`에 설치되고, 직접 빌드한 파일은 `/usr/local/bin/nvim`에 설치된다. 
`/usr/local/bin`이 PATH에 먼저 오도록 설정되어 있으므로, `nvim` 명령어를 입력하면 직접 빌드한 파일이 실행된다. 

-> 잘 되지 않으면 기존 파일을 삭제.

```bash
sudo apt remove neovim
```

## nvim-plugin setting : fd, eza

fd는 설치하려면 `fd-find`로. eza는 간단히 되지 않는다. 문서 참고. https://github.com/eza-community/eza/blob/main/INSTALL.md

```sh
sudo apt install -y fd-find
# --

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

## ubuntu vm에 qemu-guest-agent 설치

```bash
sudo apt install qemu-guest-agent
```
