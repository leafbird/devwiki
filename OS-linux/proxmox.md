# proxmox setting

## registry 설정

GUI에서 enterprise repository를 비활성화하고, community repository를 활성화한다. 


## 기본 설정은 우분투 서버 참고

기본적으로는 [ubuntu server 설정](./ubuntu server 설정.md)를 따라가면서 설치. 

* eza는 지금 리포지토리에 없기 때문에 제외하고 진행. 
* fastfetch 설치방법이 다름. 아래처럼 진행.

```bash
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.42.0/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
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