## os 버전 확인

## 개인 장비 설정

#### 키를 오래 누르고 있을 때 대체캐릭터 입력이 아닌 반복입력으로 변경하기
출처 : https://junho85.pe.kr/1462
커맨드 : defaults write -g ApplePressAndHoldEnabled -bool false

#### vim 사용 위해 한글 입력 중에 esc 누르면 영문으로 전환하기
출처 : https://mkszero.com/@케이/VIM에서-ESC키-눌렀을때-자동으로-영문-전환-하기(macos,-몬터레이)

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
