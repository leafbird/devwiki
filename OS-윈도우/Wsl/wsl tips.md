### 윈도우 실행파일을 alias로 설정

리눅스에서는 윈도우 실행파일 호출시 확장자를 생략할 수 없으나, notepad.exe 대신 notepad만으로 호출하고 싶다면 alias를 활용한다.

```sh
alias notepad=notepad.exe
```

### 심링크로 윈도우 경로에 쉽게 접근

```sh
$ ln -s /mnt/c/Users/user/Downloads/ ~/Downloads
```

사용자 프로필을 이용해 유저이름에 상관없이 링크 만들기
```sh
WIN_PROFILE=$(cmd.exe /C echo %USERPROFILE% 2>/dev/null)
WIN_PROFILE_MNT=$(wslpath -u ${WIN_PROFILE/[$'\r\n']})
ln -s $WIN_PROFILE_MNT/Downloads ~/Downloads
```

### wslview 사용

https://github.com/wslutilities/wslu?tab=readme-ov-file

윈도우의 기본 프로그램을 실행해준다. wslview 외에 wslusc, wslsys, wslfetch, ... 등이 있다.

```sh
# 설치
sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update
sudo apt install wslu
```

### SSH 에이전트 전달

1. 서비스에서 `OpenSSH Authentication`을 찾아 활성화 -> ssh-add 명령 사용 가능
2. `npiperelay.exe`를 빌드하기 위해 go를 설치 : `winget install golang.go`
3. npiperelay 빌드

```pwsh
# note : WSL 아니고 윈도우 파워쉘에서 실행합니다.
git clone https://github.com/jstarks/npiperelay.git
cd npiperelay
go build -o npiperelay.exe
```

4. npiperelay.exe를 적당한 장소에 두고 Path에 포함.
5. wsl 안에서 ln -s 이용해서 연결.

```sh
$ sudo ln -s /mnt/c/Users/<myuser>/go/bin/npiperelay.exe /usr/local/bin/npiperelay.exe
```

6. socat 설치 : `sudo apt install socat`

#### 1회성 연결

```sh
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &  
```

#### .zshrc에 설정

reference : https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/

```sh
# Configure ssh forwarding
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
# need `ps -ww` to get non-truncated command for matching
# use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
if [[ $ALREADY_RUNNING != "0" ]]; then
    if [[ -S $SSH_AUTH_SOCK ]]; then
        # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
        echo "removing previous socket..."
        rm $SSH_AUTH_SOCK
    fi
    echo "Starting SSH-Agent relay..."
    # setsid to force new session to keep running
    # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
    (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
```