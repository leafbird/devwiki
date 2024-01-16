## 심볼서버 설정

작성일 : 2019-01-16
참고자료: 
    - http://mongyang.tistory.com/77
    - 성민이형 : http://serious-code.net/doku/doku.php?id=kb:sourceserver


### requirement
* active perl : https://www.activestate.com/products/activeperl/
    - 사용한 버전은 5.26.3 Build 2603 (64-bit)
* debugging tools for windows : Windows SDK에 함께 포함 배포된다.
    - 설치가 좀 애매한데, 제대로 설치되고나면 경로는 아래와 같다.
    - C:\Program Files (x86)\Windows Kits\10\Debuggers\x64
* IIS : 공유 폴더 말고 http 로 처리.

## setting

### srcsrv.ini

스크립트 실행위치에 만들어두면 알아서 우선검색 한다. 내용 다 지우고 아래 두 개만 입력한다.

```
[variables]
MYSERVER=DESKTOP-GH9J2KL:1666

[trusted commands]
p4.exe=C:\Program Files\Perforce\p4.exe
```

MYSERVER 값을 바로 쓰는게 아니라, P4.pm 스크립트가 자체적으로 `p4 info` 명령을 실행해서 server address를 얻어낸다. 이거랑 비교해서 동일하지 않으면 제대로 실행되지 않는다. 

### execute p4index.cmd

실제 인덱싱 수행하는 파워쉘(혹은 배치파일)에서 p4index를 실행한다. 

```
&"C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\srcsrv\p4index.cmd" `
    /Symbols=..\..\\Uni.BridgeServer\bin\x64\Release `
    /Source=..\..\ `
    /Debug
```

`/Debug` 스위치는 문제 없으면 나중에 정리할 땐 뺀다. 

### indexing 확인

인덱싱 제대로 되었는지 확인하려면 pdb를 에디터로 직접 열어보아도 되고, 아래 툴을 돌려서 확인할 수도 있다. 

```
 &"C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\srcsrv\srctool.exe" `
     ..\..\Uni.GameServer\bin\x64\Release\Uni.Game.pdb
```

이것 돌려보면 몇 개가 성공했고, 몇 개를 실패했는지 알 수 있다.
```
모두 성공하면:
..\..\Uni.GameServer\bin\x64\Release\Uni.Game.pdb: 180 source files are indexed

일부 실패하면:
..\..\Uni.GameServer\bin\x64\Release\Uni.Game.pdb: 45 source files are indexed - 135 are not.

```

### symstore

대상 파일 모아두기. 필수 옵션은 아마도 /r (재귀) /f (소스) /s (대상) /t (타이틀)..??

```
&"C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\symstore.exe" `
    add /r /f ..\..\\Uni.BridgeServer\bin\x64\Release\*.* /s $TargetPath /t "CounterSide"
```

### iis setting

파일을 다운받을 수 있게 하려면 MIME 형식을 추가해 주어야 한다. 추가로, 브라우저에서 디렉토리 검색이 되도록 해두어도 좋다.

디렉토리 검색 되도록 해놓으면 web.config가 생긴다. 없으면 손으로 만들어도 된다. 
dump 모이는 루트 디렉토리의 web.config에서 다음과 같이 모든 확장자를 다운로드 가능하게 열여둔다. 

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <directoryBrowse enabled="true" />
         <staticContent>
            <clear />
            <mimeMap fileExtension=".*" mimeType="application/octet-stream" />
        </staticContent>
    </system.webServer>
</configuration>
```

참고로, 이번엔 iis를 아래처럼 구성했다. published, dump, symbols 모두 이곳으로 모음. 

HttpRoot
  - Published / Dev
  - Symbols
  - Dump

이 중에 symbols 경로는 위의 설명대로 web.config를 이용해 설정하고, .dmp 파일은 iis 관리자에서 직접 `.dmp` 확장자, `application/octet-stream` 타입을 설정했다.