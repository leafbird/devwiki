## SSH login without password

클라이언트에서 키 파일을 만들어서 서버에 등록한다.

1. 클라이언트에서 ssh-keygen -t rsa 실행. 기본 경로에 설치하고, passphrase도 넣을 필요 없음.
2. 서버에서 ~/.ssh 폴더 만든다. mkdir -p .ssh
3. 서버에서 ~/.ssh/authorized_keys 파일에 id_rsa.pub 내용을 붙여넣는다. 
    a@A:~> cat .ssh/id_rsa.pub | ssh b@B 'cat >> .ssh/authorized_keys'

## 윈도우에서 ssh server 구성

https://medium.com/beyond-the-windows-korean-edition/windows-10-%EB%84%A4%EC%9D%B4%ED%8B%B0%EB%B8%8C-%EB%B0%A9%EC%8B%9D%EC%9C%BC%EB%A1%9C-ssh-%EC%84%9C%EB%B2%84-%EC%84%A4%EC%A0%95%ED%95%98%EA%B8%B0-64988d87349

### 윈도우 OpenSSH 서버에서 키 등록

```
$authorizedKeyFilePath = “$env:ProgramData\ssh\administrators_authorized_keys”
New-Item $authorizedKeyFilePath
notepad.exe $authorizedKeyFilePath
```

### ssh 원격지에 스크립트 실행하기

https://doitnow-man.tistory.com/2
```
get-content .\temp.ps1 | ssh Buildman@192.168.0.166 
```

