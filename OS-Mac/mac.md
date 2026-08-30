## os 버전 확인

## 개인 장비 설정

#### 키를 오래 누르고 있을 때 대체캐릭터 입력이 아닌 반복입력으로 변경하기
출처 : https://junho85.pe.kr/1462
커맨드 : defaults write -g ApplePressAndHoldEnabled -bool false

적용 후 로그아웃/재로그인(또는 재부팅) 해야 반영된다. 실행 중이던 앱은 재시작 필요.
현재값 확인 : `defaults read -g ApplePressAndHoldEnabled` (0 이면 적용된 상태, 키 자체가 없으면 미적용)

#### vim 사용 위해 한글 입력 중에 esc 누르면 영문으로 전환하기
출처 : https://mkszero.com/@케이/VIM에서-ESC키-눌렀을때-자동으로-영문-전환-하기(macos,-몬터레이)

Karabiner-Elements 로 처리한다. 아래 "Karabiner-Elements 키 설정" 참고.

### Karabiner-Elements 키 설정

설정 파일 : `~/.config/karabiner/karabiner.json`
검증 : `karabiner_cli --lint-complex-modifications ~/.config/karabiner/karabiner.json`
(karabiner_cli 경로 : `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli`)

입력소스 id
- 영문 : `com.apple.keylayout.ABC`
- 한글(두벌식) : `com.apple.inputmethod.Korean.2SetKorean`

현재 걸어둔 규칙 두 가지.

1. **우측 Command 로 한/영 토글.** 카라비너에서 `right_command` 를 `f18` 로 보내고,
   시스템 설정 > 키보드 > 단축키 > 입력 소스 에서 입력소스 전환을 `f18` 로 잡아둔다.
   자세한 건 `~/dotfiles/osx/karabiner/readme.md` 참고.

   등록 확인 : `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys` 결과에서
   60(이전 입력 소스 선택) 항목이 `enabled = 1` 이고 파라미터 두 번째 값이 79(=f18)면 정상이다.

2. **Esc 누르면 영문으로 전환.** `to` 에 `escape` 와 `select_input_source`(ABC) 를 같이 넣는다.

한/영 전환은 `select_input_source` 로 입력소스를 직접 지정하는 방식도 된다.
시스템 설정 단축키가 필요 없는 대신, 현재 입력소스에 따라 분기해야 해서
`input_source_if` 조건으로 manipulator 를 두 개 만들어야 한다.
`to_if_alone` 을 같이 쓰면 우측 Command 를 조합키로도 계속 쓸 수 있다.

#### 특정 키보드에서만 리맵이 안 먹을 때 (중요)

FL·ESPORTS CMK75 (블루투스) 에서 모든 리맵이 통째로 안 먹는 일이 있었다.
설정 파일, 입력 모니터링 권한, 데몬 전부 정상인데 그 키보드만 안 되는 상황.

원인은 이 키보드가 키보드이면서 **동시에 포인팅 디바이스로 인식**되기 때문.
Karabiner 는 포인팅 디바이스를 기본적으로 무시(ignore) 하므로 해당 키보드만 리맵 대상에서 빠진다.

해결 : Karabiner-Elements 설정 > **Devices 탭 > 해당 키보드의 "Modify events" 체크**.
체크하면 karabiner.json 의 `devices` 에 아래처럼 기록된다.

```json
"devices": [
    {
        "identifiers": {
            "is_keyboard": true,
            "is_pointing_device": true,
            "product_id": 16403,
            "vendor_id": 12625
        },
        "ignore": false
    }
]
```

블루투스 저전력(BLE) 키보드는 vendor/product id 가 0 으로 잡히기도 한다.
이때는 블루투스 주소(`device_address`)로 식별한다. NuPhy Air75 V2 가 이 경우였다.

```json
{
    "identifiers": {
        "device_address": "dc-33-5c-50-a0-3b",
        "is_keyboard": true,
        "is_pointing_device": true,
        "product_id": 0,
        "vendor_id": 0
    },
    "ignore": false
}
```

같은 키보드라도 연결 방식(블루투스 / 2.4GHz 동글 / USB 유선)이 바뀌면 다른 기기로 잡히므로
그때마다 한 번씩 등록해줘야 한다.

다른 키보드는 멀쩡한데 특정 키보드만 안 되면 이 설정부터 확인할 것.

#### 새 키보드 등록 스크립트

카라비너 16.1.0 기준으로 새 기기를 자동으로 허용해주는 전역 옵션은 없다.
매번 GUI 를 여는 대신 dotfiles 의 스크립트로 등록할 수 있다.

	~/dotfiles/osx/karabiner/register-keyboards.py

연결된 키보드 중 카라비너가 무시하고 있는 것을 찾아 모든 프로필에 등록한다.
`--dry-run` 을 주면 변경 없이 확인만 한다. 실행 전 설정 파일은 자동 백업된다.

진단할 때 순서
1. EventViewer 에 키 이벤트가 뜨는지 → 안 뜨면 입력 모니터링 권한 문제
2. 이벤트는 뜨는데 리맵이 안 되면, 임시로 아무 키나 다른 글자로 바꾸는 규칙을 넣어 리맵 자체가 도는지 확인
3. 리맵은 되는데 한/영만 안 되면 f18 시스템 단축키 / 입력소스 id 쪽 문제
4. 특정 키보드에서만 전부 안 되면 위의 Devices 설정 문제

## 초기 설정

### 파인더

#### 상단에 전체경로 보이도록 변경

참고 : http://blog.naver.com/PostView.nhn?blogId=funmac&logNo=221440977778

	% defaults write com.apple.finder _FXShowPosixPathInTitle -bool true; killall Finder

#### 하단에 경로막대 보이도록 변경

메뉴 > 보기 > 경로 막대 보기


### Homebrew 설치

출처 : https://whitepaek.tistory.com/3

	% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew 설치 후 cask 바로 추가 설치 : `brew install cask`


### SSH 접속 설정

출처 : https://projectjo.tistory.com/entry/Mac-%EC%97%90-SSH-%EC%A0%91%EC%86%8D-%ED%95%98%EA%B8%B0

#### ssh 키 만들고 비번 없이 접속하기

- https://medium.com/sjk5766/ssh-%ED%8C%A8%EC%8A%A4%EC%9B%8C%EB%93%9C-%EC%97%86%EC%9D%B4-%EC%A0%91%EC%86%8D%ED%95%98%EA%B8%B0-2ad644b97c99

```
% ssh-keygen
ssh-copy-id 명령은 듣지 않는다. 수동으로 public 키를 옮겨줘야 함. 
%USERPROFILE%\.ssh로 이동해서 id_rsa, id_rsa.pub 파일 생성 확인. 
mac에 비번 입력해서 접속 후, ~/.ssh 폴더 만들고 ~/.ssh/authorized_keys 파일 만들어서 is_rsa.pub 내용 복사
ssh 재접속. 비번 없이 접속 되는 것 확인
```

### Oh My Zsh 설치

출처 : https://steemit.com/kr/@anpigon/mac

	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


### 윈도우 공유폴더 접속하기 

- https://kimsungjin.tistory.com/235

파인더 메뉴 > 이동 > 서버에 연결... 을 이용해 연결한다. 
연결하고 나면 /Volumes/ 아래에서 접근 가능하다.

항상 접속을 유지하려면 환경설정 > 사용자 및 그룹 > 계정 선택 > 로그인 항목에서 자동 실행되도록 설정해준다.

공유폴더 마운트 shell에서 설정
https://stackoverflow.com/questions/41470107/connect-to-smb-server-over-command-line

```
/usr/bin/osascript -e "try" -e "mount volume \"smb://macuser:macuser@192.168.0.145/Published\"" -e "end try"
```

마운트 해제

	umount /Volumes/Published

## java 삭제하기
https://osxdaily.com/2017/06/16/uninstall-java-mac/

```
sudo rm -rf "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"

sudo rm -rf "/Library/PreferencePanes/JavaControlPanel.prefPane"

sudo rm -rf "~/Library/Application Support/Java"
```

이렇게 지워도 팀시티 에이전트는 더 높은 버전의 java를 스스로 찾아 설정하는 것 같다. 
/Library/Java/JavaVirtualMachines/ 에 가서 불필요한 버전 폴더를 날리고, 새 버전 설치 후 reboot하면 더이상 인식하지 않는다. 

```
sudo rm -rf /Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk
# 사용하려는 다른 java 버전을 설치...
sudo reboot now
```

## hostname 변경하기

https://apple.stackexchange.com/questions/287760/set-the-hostname-computer-name-for-macos

UI 상에서 컴퓨터 이름이나 공유 이름을 변경해도 터미널 `hostname` 명령 결과값은 변경되지 않는다. 

```
sudo scutil --set HostName ST-ClientBuild05.bside.com
sudo scutil --set ComputerName ST-ClientBuild05
sudo scutil --set LocalHostName ST-ClientBuild05
dscacheutil -flushcache
```
