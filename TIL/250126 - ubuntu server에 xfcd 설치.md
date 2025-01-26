# 구형 노트북 업데이트

## 모니터 밝기 조정

ddcutil을 이용한 방법은 동작하지 않는다. 모니터가 DDC/CI를 지원해야 하는데 내 노트북은 아닌 듯.

시스템 파일을 직접 수정 (루트 권한 필요)

### 백라이트 장치 경로 확인:

```
ls /sys/class/backlight/
```

출력 예시: intel_backlight 또는 acpi_video0.

### 현재 밝기 확인:

```
cat /sys/class/backlight/intel_backlight/brightness
```

### 최대 밝기 확인:

```
cat /sys/class/backlight/intel_backlight/max_brightness
```

### 밝기 조정:

```
echo 1000 | sudo tee /sys/class/backlight/intel_backlight/brightness
```

### 밝기 조정 스크립트:

```bash
#!/bin/bash

# 밝기 조정 스크립트
# 사용법: ./brightness.sh [up|down] [step]

# 밝기 장치 경로
BACKLIGHT_PATH="/sys/class/backlight/intel_backlight"

# 밝기 최대값
MAX_BRIGHTNESS=$(cat $BACKLIGHT_PATH/max_brightness)

# 현재 밝기
CURRENT_BRIGHTNESS=$(cat $BACKLIGHT_PATH/brightness)

# 밝기 조정량
STEP=${2:-100}

# 밝기 조정 방향
case $1 in
    up)
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + STEP))
        ;;
    down)
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - STEP))
        ;;
    *)
        echo "Usage: $0 [up|down] [step]"
        exit 1
        ;;
esac

# 최대값 보정
if [ $NEW_BRIGHTNESS -gt $MAX_BRIGHTNESS ]; then
    NEW_BRIGHTNESS=$MAX_BRIGHTNESS
fi

# 최소값 보정
if [ $NEW_BRIGHTNESS -lt 0 ]; then
    NEW_BRIGHTNESS=0
fi

# 밝기 조정
echo $NEW_BRIGHTNESS | sudo tee $BACKLIGHT_PATH/brightness
```

### 밝기 조정 스크립트 사용법:

```
chmod +x brightness.sh
./brightness.sh up 100
./brightness.sh down 100
```


## neofetch 대신 fastfetch

neofetch는 더이상 업데이트되지 않는다. 대신 fastfetch를 사용하자.

https://launchpad.net/~zhangsongcui3371/+archive/ubuntu/fastfetch

## ubuntu 22 -> 24 upgrade

조금 사용하다보니 로그인할 때 업데이트 안내가 나온다. 
알려준 명령으로 업그레이드 진행. 시간은 꽤 걸립니다.

```bash
New release '24.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.
```


## xfce4 설치

```bash
sudo apt install xfce4
```