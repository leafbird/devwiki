## 한글 설정

https://xangmin.tistory.com/16



## 기본 설정

```
xset r rate 180 # 키보드 반복속도 향상

suto apt install htop
sudo apt install git # git 설치
git clone https://github.com/leafbird/dotfiles.git
bash ~/dotfiles/script/setup.sh #dotfile 적용
```



## vnc 서버 설치

https://z-wony.tistory.com/19

```
sudo apt install tigervnc-standalone-server tigervnc-xorg-extension
vncpasswd # 비번 설정. 중간에 읽기전용? 무엇을 물으면 no.
vi ~/.vnc/xstartup # 파일 만들면서 아래 내용 입력

#!/bin/sh 
# Start Gnome 3 Desktop 
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup 
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources 
vncconfig -iconic & 
dbus-launch --exit-with-session gnome-session &

vncserver -localhost no # vnc 실행.
vncserver -list # 서버 실행상태 확인.
```



## ssh 서버 설치

https://codechacha.com/ko/ubuntu-install-openssh/

```
sudo apt install openssh-server
sudo systemctl status ssh # 실행여부 확인

실행중이지 않을 때 실행하기
sudo systemctl enable ssh 
sudo systemctl start ssh
```



## 클램쉘 모드 설정하기

https://wiki.debian.org/Suspend

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target # 클램쉘 on
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target # 클램쉘 off
```

