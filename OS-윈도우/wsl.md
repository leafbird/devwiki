## WSL2에서 vmmem 메모리 이슈 해결하기

출처 : https://itun.tistory.com/612

%UserProfile%\.wslconfig 파일을 만들어서 wsl 메모리 자체를 제한하면 된다.

```
[wsl2]
memory=1GB
swap=0
localhostForwarding=true
```

파일의 내부는 상단처럼 작성하면 된다.


## WSL1에서 distro 삭제하기

출처 : https://superuser.com/questions/1317883/completely-uninstall-the-subsystem-for-linux-on-win10

	wslconfig /l -- 목록 확인
	wslconfig /u Ubuntu -- 이름으로 삭제
	
