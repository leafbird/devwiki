## export

사전 준비 : `/etc/wsl.conf`에 기본 사용자 설정하기

```sh
$ cat /etc/wsl.conf # 기본 사용자 지정 여부 확인
$ sudo bash -c "echo -e '\n[user]\ndefault=$(whoami)' >> /etc/wsl.conf" # 현재 사용자를 설정에 등록
```

내보내기:

```pwsh
$ wsl --export Ubuntu D:\Ubuntu.tar
```


## import

가져오기 : 

```pwsh
wsl --import [배포판 이름] [디스크상 위치] [압축파일 위치]
$ wsl --import Ubuntu-20.04-Copy c:\wsl-distros\Ubuntu-20.04-Copy c:\temp\Ubuntu-20.04.tar
```

## 도커 컨테이너에서 가져오기

파워쉘에서 컨테이너 준비

```pwsh
이미지 가져오기
docker pull mcr.microsoft.com/dotnet/sdk:9.0
컨테이너 생성
docker run -it --name dotnet mcr.microsoft.com/dotnet/sdk:9.0
```

컨테이너 내에서 유저 생성

```sh
useradd -m florist
password florist
echo -e "[user]\ndefault=florist" > /etc/wsl.conf
cat /etc/wsl.conf
exit
```

파워쉘에서 익스포트하고 wsl에서 임포트

```pwsh
docker export -o D:\dotnet.tar dotnet
wsl --import dotnet C:\wsl-distros\dotnet D:\dotnet.tar
```

위 내용을 dockerfile로 만들어서 자동화 할 수 있다.

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0

ARG USERNAME
ARG PASSWORD

RUN useradd -m ${USERNAME}
RUN bash -c "echo -e '${PASSWORD}\n${PASSWORD}\n' | passwd ${USERNAME}"
RUN bash -c "echo -e '[user]\ndefault=${USERNAME}' > /etc/wsl.conf"
RUN usermod -aG sudo ${USERNAME}
RUN apt-get update && apt-get install -y sudo
```

```pwsh
도커 이미지를 만든다. -t : 태그, -f : 파일
docker build -t dotnet-test -f Dockerfile --build-arg USERNAME=florist --build-arg PASSWORD=[비번] .

이미지에서 컨테이너를 생성 - 익스포트 - 삭제.
docker run --name dotnet dotnet-test
docker export -o D:\dotnet-test.tar dotnet
docker rm dotnet

wsl에서 임포트
wsl --import dotnet-test C:\wsl-distros\dotnet-test D:\dotnet-test.tar
```