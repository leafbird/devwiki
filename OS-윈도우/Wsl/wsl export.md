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