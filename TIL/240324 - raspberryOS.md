## Raspberry Pi OS Lite 설치

이전에 pi3에 쓰고 있던 os가 32bit인 것을 확인한 후, 64bit lite 버전을 새로 설치해보았다.

## 설치 후 최초 기본 설정 : sudo raspi-config

ssh 활성화 : 3 interface - 1 ssh
hostname 간단하게 변경 : 1 system - 4 hostname
키보드 레이아웃 : 4 localization - 3 keyboard
  - Generic 101-key PC > Korean - Korean (101/104-key compatible)
  - 그냥 디폴트로 설정하면 파이프 '|' 같은 기호를 제대로 칠 수 없어서 불편하다. 
  
## ssh 키 복사

서버에서 ~/.ssh 폴더 생성 : mkdir -p .ssh
클라에서 cat .ssh/id_rsa.pub | ssh pi@pi3 'cat >> .ssh/authorized_keys'
  
## apt source 변경

```
$ sudo vi /etc/apt/sources.list
[vi command] %s/raspbian.raspberrypi.org/ftp.kaist.ac.kr/g
```

## swap 파일 사이즈 키우기

``` shell
sudo service dphys-swapfile stop
sudo vi /etc/dphys-swapfile -> 들어가서 1024로 변경.
sudo service dphys-swapfile start
```
  
## bash -> zsh

```shell
$ sudo apt install zsh 
$ sudo apt install git
$ sudo apt install vim # 기본버전은 컬러링이 안됨.
$ sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
$ git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
$ git clone https://github.com/leafbird/dotfiles.git
```
## install docker

참고 : https://ban2aru.tistory.com/70

```sh
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ${USER} # 비루트 권한 실행 설정
groups ${user} # pi의 소속 그룹 확인
sudo reboot now # 그룹정책 변경 적용을 위해 리붓
```

## install portainer

```sh
docker volume create portainer_data
docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```
browse : https://pi3:9443

