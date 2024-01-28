## Gyp to sln

gyp 메인 페이지 : https://code.google.com/p/gyp/
git으로 복사된 코드 : https://github.com/svn2github/gyp

gyp: Cycles in .gyp file dependency graph detected 에러 해결법:
 > gyp --no-circular-check XXX.gyp
 
## breakpad sln파일 만들기.

note : 원본 버전의 소스만 받아라. github.com/svn2git에 올라온 것도 받아보고 git svn으로도 받아봤지만 다 이상하다. 반드시 svn client를 설치하고 아래 명령으로 받을 것.

 svn checkout http://google-breakpad.googlecode.com/svn/trunk/ google-breakpad-read-only

v8의 빌드를 설명한 다음 글을 참고 : https://code.google.com/p/v8-wiki/wiki/BuildingWithGYP

+++ 사전에 필요한 것
 - python 2.x
 - gyp code (svn co http://gyp.googlecode.com/svn/trunk gyp)
  - 만약 제대로 된 버전을 받았다면 tools 아래에 이미 포함되어 있다. 
 
+++ 빌드하기
 - brakpad 코드의 root로 간다. 이곳에서 cmd 창을 연다. 

<<pre
    src\tools\gyp\gyp.bat src\client\windows\breakpad_client.gyp --no-circular-check
>>