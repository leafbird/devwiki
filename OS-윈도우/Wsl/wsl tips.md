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