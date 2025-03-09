## 부팅하면 hyprland로 바로 진입하기

https://grok.com/chat/e463a9f5-8def-4afa-b67d-9935043293f7

디스플레이 매니저 (gdm, sddm, lightdm 등)을 사용하는 것이 추천됨. gdm은 GNOME 사용시에, sddm은 KDE Plasma 사용시에 쓰임.

sddm을 설치하고 설정한다.

```sh
sudo pacman -S sddm # 설치
sudo systemctl enable sddm # 부팅시 자동 실행
```

Hyprland 세션 설정 확인 Hyprland는 Wayland 기반이므로, SDDM이 Hyprland를 인식할 수 있도록 데스크톱 파일이 설치되어 있어야 합니다. 일반적으로 `hyprland` 패키지를 설치하면 `/usr/share/wayland-sessions/hyprland.desktop` 파일이 자동 생성됩니다. 확인해보세요:

```sh
ls /usr/share/wayland-sessions/
```

### 디스플레이 매니저 없이 실행 (직접 실행)

```sh
vim ~/.zprofile

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
```

## UWSM : Universal Wayland Session Manager

uwsm-managed는 **Universal Wayland Session Manager (UWSM)**라는 도구를 통해 관리되는 Wayland 세션을 의미합니다. UWSM은 Wayland 기반 컴포지터(예: Hyprland)를 systemd 유닛으로 감싸서 실행하는 방식으로, 세션 관리에 다음과 같은 기능을 제공합니다:

* 환경 변수 관리 (예: WAYLAND_DISPLAY 설정)
* XDG autostart 지원 (부팅 시 앱 자동 실행)
* 로그인 세션과 그래픽 세션 간의 양방향 바인딩
* 깔끔한 종료 처리

```sh
sudo pacman -Qs uwsm # 설치 확인

# 설치되어 있지 않다면 설치
sudo pacman -S uwsm

# 로그 확인 : UWSM 세션 실패 시 로그 확패
journalctl -xe
```


## 자동 로그인 설정

```sh
sudo vim /etc/sddm.conf.d/autologin.conf

[Autologin]
User=your-username
Session=hyprland.desktop
```

## 키보드 반복속도 설정

```sh
vim ~/.config/hypr/hyprland.conf

input {
    repeat_delay = 180
    repeat_rate = 30
}
```

## 런처, 상태바

```sh
sudo pacman -S waybar wofi
sudo pacman -S ttf-font-awesome # waybar 아이콘 폰트
sudo pacman -S ghostty # 터미널
sudo pacman -S nautilus # 파일 관리자

yay -S hypershot grim slurp # 스크린샷
yay -S swaync # notification
```
