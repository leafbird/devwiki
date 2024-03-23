## headless install

root 경로에 빈 ssh 파일을 만든다. ssh가 활성화됨.
root 경로에 wpa_suppllicant.conf 파일을 만들고 wifi 접속 정보를 설정한다. 
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US
network={
    ssid="접속할 WIFI 이름"
    psk="접속할 WIFI 암호"
}
```

라즈베리파이 초기 암호는 pi / raspberry.

```
# apt 업데이트를 한 번 진행한다.    
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove

# 설정을 연다
sudo raspi-config

hostname을 간단하게 바꿔준다.

한글 사용위해 locale은 language en(English) country US (United States) Character Set UTF-8로 설정한다.

$ sudo apt install -y fonts-unfonts-core # 한글 읽기만 하려면 이것으로 충분
$ sudo apt install ibus-hangul # 한글 입력을 하려면 이것 필요 
```

## swap 사이즈 늘리기

참조 : https://bugwhale.tistory.com/entry/raspberrypi-raspbian-swap-memory

``` shell
free -h # 현재 용량 확인
sudo service dephys-swapfile stop # 서비스 정지 
sudo vi /etc/dephys-swapfile # 설정파일 열기 - CONF_SWAPSIZE를 1024로하면 1기가.
sudo service dephys-swapfile start # 서비스 시작
````

## apt source 변경

```
$ sudo vi /etc/apt/sources.list
수정전
deb http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi
수정후
deb http://ftp.kaist.ac.kr/raspbian/raspbian/ buster main contrib non-free rpi

$ sudo apt update # 동작 확인.
```

## 삼바 설정
https://geeksvoyage.com/raspberry%20pi/samba-for-pi/

```
$ sudo apt-get install samba samba-common-bin
$ sudo smbpasswd -a pi # pi 계정 비번 설정.
$ sudo vi /etc/samba/smb.conf # 설정에 pi 계정의 내용 추가 ------------------
[pi]
comment = raspberry pi 3b+ for TeamcityMonitor
path = /home/pi
valid user = pi
read only = no
browseable = yes
----------------------------

$ sudo /etc/init.d/samba restart # 설정 적용을 위한 재시작
$ sudo /usr/sbin/samba restart # samba 위치가 달라서 에러나면 이렇게. 아니면 which로 찾아서 처리.
```


## docker 설치
https://phoenixnap.com/kb/docker-on-raspberry-pi

    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

## 파워쉘 설치

https://geektechstuff.com/2019/09/25/installing-powershell-core-on-raspbian-rasbperry-pi/

```
wget https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/powershell-7.0.3-linux-arm32.tar.gz
mkdir ~/powershell
tar -xvf ./powershell-7.0.3-linux-arm32.tar.gz -C ~/powershell

vim ~/.zshrc
    # set powershell path
    PATH=$PATH:~/powershell

source ~/.zshrc # reboot 없이 수정내용을 바로 적용
```


## 와이파이 문제 해결

https://blog.naver.com/elepartsblog/221509219517
https://blog.naver.com/elepartsblog/221509228144

국가 설정에 따라 사용 가능한 주파수가 달라져서 장애가 발생한다. 
wifi 국가를 US로 설정하고, iw phy 실행해서 사용 가능한 채널을 확인한 후 공유기 설정을 맞춰주면 2.4g는 사용 가능하다. 
wifi 국가를 KR로 설정하고, 채널을 149, 153, 157, 161로 맞춰주면 5G도 사용 가능.

## 와이파이 설정 관련 명령어들
https://wikidocs.net/3200

```
sudo iwlist wlan0 scan # wifi 네트워크 스캔
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf # 설정파일 위치
wpa_cli -i wlan0 reconfigure # 인터페이스 재구성
ifconfig wlan0 # 성공적으로 연결 되었는지 확인. inet addr 필드 옆에 주소가 있으면 결

```

## 하드웨어 정보 확인하기

출처 : https://www.raspberrypi.org/forums/viewtopic.php?t=111691

    cat /proc/cpuinfo
    cat /sys/firmware/devicetree/base/model

## 버전별 스펙

https://namu.wiki/w/%EB%9D%BC%EC%A6%88%EB%B2%A0%EB%A6%AC%20%ED%8C%8C%EC%9D%B4(%EC%BB%B4%ED%93%A8%ED%84%B0)#s-3


## 키오스크 모드 설정

출처 : https://medium.com/@alexjv89/setting-up-a-dashboard-on-raspberry-pi-4e6e2e37ddbb
```
mkdir /home/pi/.config/autostart
vi /home/pi/.config/autostart/kiosk.desktop

# kiosk.desktop 파일 본문 ----------------------------------
[Desktop Entry]
Type=Application
Name=Kiosk
Exec=/home/pi/kiosk.sh
X-GNOME-Autostart-enabled=true
-------------------------------------------------------------

# Now create kiosk.sh file.
vi /home/pi/kiosk.sh

# kosk.sh 파일 본문----------------------------------
#!/bin/bash
# Run this script in display 0 - the monitor
export DISPLAY=:0

# Hide the mouse from the display
unclutter &

# If Chrome crashes (usually due to rebooting), clear the crash flag so we don't have the annoying warning bar
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

# Run Chromium and open tabs
chromium-browser --kiosk ~/TeamcityMonitor/index.htm
#sleep 10s
#chromium-browser https://grafana.highlyreco.com/dashboard2 
--------------------------------------------------------------------

Make the script executable by running chmod +x /home/pi/kiosk.sh

Disable screen saver:
Open the GUI from preference->screensaver. From the dropdown, choose to Disable screen saver .

```

## mono 설치
https://www.mono-project.com/download/stable/#download-lin

### add mono repository to your system
```
sudo apt install apt-transport-https dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/debian stable-raspbianstretch main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
```

### install Mono
    sudo apt install -y mono-complete


## 5 inch touch display setting
출처 : https://github.com/goodtft/LCD-show
원본(으로 추정되는) 드라이버 : https://github.com/waveshare/LCD-show

장치 이름: ADS7846 Touchscreen

## rotate screen
/boot/config.txt 파일에 display_rotate=2 추가. 0:0도 1:90도 2:180도 3:270도


## 참고자료 

Raspberry Pi Geek : https://geeksvoyage.com/pi-guide/
raspberry pi에 .NET Core 설치 : https://www.hanselman.com/blog/BuildingRunningAndTestingNETCoreAndASPNETCore21InDockerOnARaspberryPiARM32.aspx


## 참고 : 데스크탑에서 키오스크 모드 설정하기
배치파일 만들어서 시작 프로그램에 넣어둔다. (실행창에 shell:startup)
```
call "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --kiosk http://build02:8080/TeamcityMonitor/
```
