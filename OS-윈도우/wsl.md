## 기본적인 명령

```pwsh
wsl --install # 쉬운 설치
wsl --set-default-version 2 # 기본 버전 설정

wsl --list # 설치된 배포판 목록
wsl --list --running # 실행중인 배포판 목록
wsl --list --verbose # 상태 및 버전 정보 확인

wsl --set-version Ubuntu 2 # 설치한 배포판의 버전 변경

# wsl로 리눅스 명령 실행. 배포판을 지정하거나 유저를 지정하면서 실행.
wsl cat /etc/issue
wsl -d docker-desktop cat /etc/issue
wsl -u root whoami

wsl --terminate ubuntu # 실행중인 배포판을 중단
wsl --shutdown # wsl과 실해중인 모든 배포판 종료
```

## 기본 정보

배포판의 기본 설치 위치 : `배포판이름` 부분은 `CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc` 같은 식이라 눈으로 찾기는 어렵다.
```
C:\Users\<유저이름>\AppData\Local\Packages\<배포판이름>\LocalState
```

## 설정파일

상세 설명 : https://learn.microsoft.com/ko-kr/windows/wsl/wsl-config

### wsl.conf

배포판 별로 하는 설정. 
각 배포판의 `/etc/wsl.conf` 에 위치.

### .wslconfig

모든 배포판에 적용되는 설정. 
`%UserProfile%.wslconfig` 에 위치.


## Troubleshooting

#### WSL2에서 vmmem 메모리 이슈 해결하기

출처 : https://itun.tistory.com/612

%UserProfile%\.wslconfig 파일을 만들어서 wsl 메모리 자체를 제한하면 된다.

```
[wsl2]
memory=1GB
swap=0
localhostForwarding=true
```

파일의 내부는 상단처럼 작성하면 된다.
