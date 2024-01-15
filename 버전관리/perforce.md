## 비번 확인하는 티켓 만료주기 변경

운영자툴에서 group 에 속성이 있다. 커맨드 명령 p4 group XXX 에서 초단위 설정도 가능. 
https://www.perforce.com/manuals/p4sag/Content/P4SAG/superuser.basic.auth.tickets.html

티켓 방식이 아니라 P4PASSWD를 쓰면서, md5 해쉬만으로 설정할 수도 있다.
https://community.perforce.com/s/article/3413

## diff / merge 툴에 utf8 인코딩 설정하기 

argument의 가장 앞에 `-C utf8`을 붙인다. 

    Diff : -C utf8 %1 %2
    Merge : -C utf8 %b %1 %2 %r

## 백업하기

성민이형 위키에 기본 개념과 방법은 잘 정리되어 있음 
http://serious-code.net/doku/doku.php?id=kb:perforcebackup

## 복원하기
checkpoint 파일만 있으면 메타 데이터는 복원 가능. 

    p4d -r $P4ROOT -jr checkpoint_file

depot 하위 파일은 수동으로 복원해준다. 

## 자식 stream의 내용을 부모 stream의 내용과 동일하게 맞추기(accept source merge보다 강력함)
출처 : https://forums.perforce.com/index.php?/topic/2432-restore-stream-to-parent/
    p4 copy -F -S //자식스트림 -r
* -F force 옵션
* -S 스트림 지정인데, 기본으로 방향이 from stream to its parent이다. 
* -r -S와 함께 쓰여서 복사 방향을 부모 -> 자식으로 변경한다. 


## p4 set에 설정되지 않은 유저, 클라이언트 정보로 명령 실행하기

출처 : https://forums.perforce.com/index.php?/topic/723-using-p4-sync-specifying-a-password/
    p4 -c Kurt_Build -p breakout:1683 -u build -P Foo sync //depot/...

## local depot(스트림 미지원)을 stream depot으로 변경하기

copy나 duplicate나 모두 빨리 끝난다. 실제로 파일을 복사하진 않는다 (복사는 p4 snap이라고 따로 있음)

부드러운 전환을 하려면 
1. p4 copy -v //depot/... //stream/dev/... 해서 복사로 파일을 만들고, 
2. local depot을 쓰기, stream depot을 읽기로 만들어 매뉴얼 작성 및 사용자들에게 안내를 하고 
3. 실제 적용시에 변경점들을 다시 integration한 후 local은 읽기, stream depot을 쓰기로 변경한다. 
4. local depot은 한 동안 유지. 
... 의 방법이 깔끔해 보인다. 

local depot은 보이지도 않게 해놓고 그냥 server에만 존재시켜도 무방할 것 
하지만 이마저 정리하고 싶다면

1. p4 snap //stream/dev/... //depot/... 으로 파일을 복사하고, 로컬파일의 연결을 끊는다.
2. p4 obliterate -y //depot/... 으로 파일을 지운다 (파일이 있으면 depot 삭제가 안됨)
3. p4 depot -d depot 으로 로컬 depot을 지운다. 

의 과정으로 제거 가능하다. 
이렇게 지워도 stream 내의 파일들 사용은 문제가 없지만, revision graph가 과거의 연결은 보여는 주는데 애매하게 보여줌. 이럴바에는 그냥 유지하는 것이 좋아보인다. 
p4 snap을 하지 않았다면 server의 파일도 사본 생성이 아니기 때문에 용량 이슈도 없음.


참고 : Migrating from Classic to Stream Depot - https://community.perforce.com/s/article/2477
copy하는 방법, DVCS를 이용하는 방법을 소개하고 있다.
copy로 하는 방법의 핵심은 아래. 
```
p4 copy -v //depot/Titan/MAIN/... //titan/main/...
p4 submit –d "seeding Titan stream mainline"
```

참고2 : https://forums.perforce.com/index.php?/topic/5634-migrating-classic-depot-to-streams-depot/
duplicate 명령을 이용하는 방법을 소개하고 있다.

stream 지원용 depot을 새로 만든 후, duplicate 명령으로 내용을 수동 복사한다.

```
p4 duplicate //classic-depot/... //stream-depot/...
p4 obliterate -y //classic-depot/...
```

## perforce server 업그레이드 하기

참고 : https://www.perforce.com/perforce/doc.current/manuals/p4sag/Content/P4SAG/install.upgrade.2013.2_and_earlier.html

1. `p4d -vx`와 `p4d -xx` 명령으로 db.* 파일이 업그레이드 가능한지 확인
2. p4 verify -q //... 
3. p4 서비스 중지. (Stop-Service Perforce | net stop Perforce | p4 admin stop)
3. 백업. checkpoint 파일 만들어 옮기고, depot 파일도 side effect를 대비해 옆으로 잠시 치워둔다.
4. p4d 실행파일을 새 버전으로 변경. 인스톨 파일을 실행한다.
5. 진정한 업그레이드: `p4d -r server_root -J journal_file -xu`
6. 옆으로 치워둔 depot을 다시 옮기고, p4 서비스 시작 (Start-Service Perforce | net start Perforce)

## 2018.2 -> 2020.1 업그레이드
참고 : https://www.perforce.com/manuals/p4sag/Content/P4SAG/upgrade-to-new-single-server.html

1. p4d -vx, p4d -xx 과정은 문서에 소개가 없다. p4d -h 에도 설명이 없다. 안해도 될듯. 
2. p4 verify 오래 걸려서 생략
3. p4 서비스 중지. (Stop-Service Perforce | net stop Perforce | p4 admin stop)
4. 백업. checkpoint 파일 만들어 옮기고, depot 파일도 side effect를 대비해 옆으로 잠시 치워둔다.
5. p4d 실행파일을 새 버전으로 변경. 인스톨 파일을 실행한다.
    인스톨 파일이 서비스 시작을 시도하고 실패했다고 팝업 출력. 에러로그 보면 업그레이드 하라는 안내가 있다. 
        Database is at old upgrade level 31.  Use 'p4d -r C:\PerforceServer -xu' to upgrade to level 36.
6. 진정한 업그레이드: `p4d -r server_root -J journal_file -xu`
    -J는 안해도 될듯하다. 기본 이름이 journal이라서, -J journal 해주면 된다. 
7. 옆으로 치워둔 depot을 다시 옮기고, p4 서비스 시작 (Start-Service Perforce | net start Perforce)
    서비스가 이미 시작되고 있었다. 실행 주체는 p4d 명령인지, 윈도우 서비스 (인스톨 파일이 실행했다 실패해서) 인지 명확하지 않다. 인스톨러로 인한 서비스쪽인듯.
8. `p4 storage -w` 명령으로 백그라운드 작업 완료여부를 확인하라는데, 바로 완료되어있었다.

## 2020.1 -> 2020.2 업그레이드
https://www.perforce.com/manuals/p4sag/Content/P4SAG/upgrade-from-2019x-single-server.html
1. p4 verify 오래 걸려서 생략
2. p4 서비스 중지. (Stop-Service Perforce | net stop Perforce | p4 admin stop)
3. 백업. 디스크 공간이 모자라서 백업에 실패했다. 구 depot 폴더를 symlink로 옮긴 후 재시도 하여 성공했다. 
4. depot 파일을 옆으로 치워두고 인스톨 파일 실행. 
    오류 팝업 발생. 
    Perforce service failed to start. After completing installation, 
    please contact Perforce tachnical support(support@perforce.com) for assistance. Additional information may be found in this service's log file located in the installation directory by default.
    p4root 폴더의 log 파일 열어보면
        Database is at old upgrade level 36.  Use 'p4d -r C:\PerforceServer -xu' to upgrade to level 39.
5. 진정한 업그레이드: `p4d -r C:\PerforceServer -xu`
6. 옆으로 치워둔 depot을 다시 옮긴다. p4 서비스는 주기적으로 재시작 시도가 진행중이기 때문에, 업그레이드만 되면 곧 시작된다.



## 특정 확장자에 exclusive checkout 설정하기

참고자료 : https://community.perforce.com/s/article/3114

기본적으로는 파일타입에 +l 이 추가되면 완성. 
```
p4 typemap

#ex: xlsx 확장자에 해당 설정을 하는 경우 다음을 기입
    +l //stream/....xlsx #콜론이 네 개.
```

위 설정은 새롭게 add되는 파일에만 적용된다.
기존에 등록된 파일, 사용중인 workspace는 해당 사항이 적용되지 않아, 추가 작업이 필요하다. 

```
p4 retype -t +l //stream/....xlsx
```

위 설정으로 등록된 파일의 타입도 변경되었으나, 기존의 workspace들은 파일을 여는 순간 다시 +l을 떼버린다. 

```
p4 edit -t +l //stream/....xlsx
p4 submit -d "change file types to exclusive-checkout"
```

위 설정은 단순히 submit을 한 번 더 실행할 뿐. 누군가 작업중이어서 submit에서 누락이 되었다면 그 파일은 다시 +l이 빠질 수 있는 위험이 있다.


### Misc.

 가장 최근 리비전 번호 알아내기 : p4 changes -m1 //depot/...

### depot에 있는 파일 수정되게 하기

기본적으로 p4 edit -> p4 revert -a 하면 수정한 후 변경 안 된 파일만 되돌릴 수 있지만, 연속으로 실행되는 프로세스들이 종료되기 직전 실행되면서 씹히는 현상이 발생. 

이를 회피하기 위해선 일단 readonly 속성을 제거해서 파일 수정을 먼저 한 후, 변경이 발생한 파일만 checkout 하는 게 좋다. 

c# 기준에서 readonly를 제거하려면 간략하게 아래처럼 가능하다.

    File.SetAttributes(fileName, FileAttributes.Normal); 

이렇게 하면 파일의 모든 속성(숨김, 시스템 등..)이 제거되지만, 개발에 쓰일 generated 파일 정도라면 큰 문제는 없다. 

그 다음 수정. 수정된 파일의 리스트를 별도로 기억한다. 

수정을 모두 마치고 나면 변경된 것만 checkout. 파일 각각에 아래 명령어 시행

 p4 diff -se filename | p4 -x - edit

-se 옵션은 checkout되지 않은 파일이면서, 원본 파일과 다른 파일의 이름만을 알려준다. 수정되지 않은 파일이면 아무 것도 리턴되지 않는다. 
파일이 수정되어 파일의 이름(경로)가 반환되면 파이프 |를 통해 다음 명령어로 전달. p4 -x가 이를 받는다.

 p4 -x file : read named files as xargs

파일이름 부분을 -로 하면 앞에서 넘어온 인자를 받게됨. 그래서 p4 edit가 실행된다.


### workspace 이름 변경하기

참조 : http://answers.perforce.com/articles/KB/3428

Solution    
Perforce does not provide a rename mechanism for client workspaces. However, if a user does not have any files checked out the following procedure can be used to create a new workspace using the same specifications as the old one and update the server's meta data.

1. Use the old workspace as a template to create a new one.
    p4 client -t old-workspace new-workspace
    Double check that the Root: is the same for the old and new workspace.

2. Update the server metadata with the revisions synced to the new workspace.
    p4 -c new-workspace sync -k @old-workspace

3. Check the list of files synced to the new client workspace.
    p4 -c new-workspace have

4. Delete the old client workspace.
    p4 client -d old-workspace

## depot files 위치 변경하기 
https://community.perforce.com/s/article/2559
세 가지 방법이 있음. 3번이 제일 쉬움.
```
1. Use the server.depot.root configurable (introduced in 2014.1).
2. Modify the depot Map: path.
3. Use symlinks to modify one or more depot paths.
```
