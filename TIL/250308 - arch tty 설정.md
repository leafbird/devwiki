## tty font 설정

https://bbs.archlinux.org/viewtopic.php?id=134370

```sh
cd /usr/share/kbd/consolefonts 
setfont font_name

setfont -d # double. 폰트 크기를 2배로 키워준다.
```

## getty 대신 kmscon 설치

https://www.reddit.com/r/archlinux/comments/tjj218/question_how_do_you_get_smooth_tty_text_on_4k/?rdt=34711

```sh
yay -S kmscon # 다운로드
yay -S nerd-fonts-hack

# 설정파일 생성
mkdir -p /etc/kmscon
sudo nvim /etc/kmscon/kmscon.conf

font-name=Hack Nerd Font
font-size=16

# 기존 getty를 kmscon으로 변경. getty를 중지해야 제대로 작동한다.
# ssh로 다른 터미널을 열어서 작업했다.
sudo systemctl stop getty@tty1.service
sudo systemctl disable getty@tty1.service

sudo /usr/lib/kmscon/kmscon # kmscon 수동 실행. 정상 동작하는지 확인.

# kmscon을 서비스로 등록
sudo systemctl enable kmsconvt@tty1.service
sudo systemctl start kmsconvt@tty1.service

systemctl status kmsconvt@tty1.service # 상태 확인
sudo journalctl -u kmsconvt@tty1.service # 로그 확인
```

임시 복구 : kmscon이 계속 실패하면 기존 getty로 돌아갈 수 있습니다

```sh
sudo systemctl stop kmsconvt@tty1.service
sudo systemctl start getty@tty1.service
```

## kmscon에 hack nerd font 적용

grok이 yay로 font를 받으라고 했지만 해당 이름이 존재하지 않았다. 

직접 설치할 때는 폰트 위치가 중요하다.

```sh
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip -O /tmp/Hack.zip

mkdir -p ~/.local/share/fonts
unzip /tmp/Hack.zip -d ~/.local/share/fonts/ # 여기. 위치가 잘못된 듯.

fc-cache -fv # 폰트 캐시 갱신

fc-list | grep -i "Hack Nerd" # 폰트 확인
```

폰트 위치 이동

```sh
sudo mkdir -p /usr/share/fonts/nerd-fonts
sudo cp -r ~/.local/share/fonts/HackNerdFont* /usr/share/fonts/nerd-fonts/

sudo fc-cache -fv # 폰트 캐시 갱신

fc-list | grep -i "Hack Nerd" # 폰트 확인

sudo systemctl restart kmsconvt@tty1.service # kmscon 재시작
```