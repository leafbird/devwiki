# IIS

## error 해결

 * 확장 구성 때문에 요청한 페이지를 처리할 수 없습니다. 페이지가 스크립트인 경우 처리기를 추가하십시오. 파일을 다운로드해야 하는 경우 MIME 맵을 추가하십시오.
 * http://pjongsik.tistory.com/55
 * 제어판 > 프로그램 > 프로그램 및 기능 > Windows 기능 사용/사용 안 함 > 인터넷 정보 서비스 > World Wide Web 서비스 > 응용 프로그램 개발 기능 을 선택하면 위 같은 화면이 뜬다. 사용하는 웹소스에 따라 ASP 나 ASP.NET을 선택해주면 된다.

 * 파일 업로드를 위한 폴더의 권한 설정 
 * http://nstyle.egloos.com/2668164
 * 해당 폴더의 속성 -> 보안 탭에서 IIS_IUSRS 그룹과 IUSR 사용자에게 쓰기 등 모든 권한을 허가해준다. (간혹 IIS_IUSRS에만 권한을 추가하면 안 되는 경우가 있는데 이때 IUSR에게도 권한을 추가하면 된다.)

 ## Web Deploy
 
 배포하는데 아래 두개의 윈도우 서비스가 관여한다. 
 
 * MsDepSvc : Web Deployment Agent Service. 이 서비스가 8172 포트를 사용한다. WebDeploy를 설치해야하고, 설치시 사용자 지정으로 가서 모든 설치옵션을 직접 활성화 해주어야 한다.
 * WMSvc : Web Management Service. 

참고 : 

* http://forums.iis.net/t/1214744.aspx?Could+not+connect+to+remote+computer+web+deploy+ERROR_DESTINATION_NOT_REACHABLE
* http://www.iis.net/learn/install/installing-publishing-technologies/installing-and-configuring-web-deploy-on-iis-80-or-later
* http://www.iis.net/learn/publish/troubleshooting-web-deploy/troubleshooting-web-deploy-problems-with-visual-studio

### 로컬에 publish한 zip 파일을 iis에 올리기

 위의 두 서비스 중 MsDepSvc를 이용한다. iis쪽 설정은 적당히 잘 해결하기 바란다. 클라이언트 쪽의 가이드는 아래와 같다. 

 1. 배포시 함께 생성된 *.SetParameters.xml 파일에 웹 사이트의 이름을 적는다(혹은 app pool name일지도 모름. 잘 해결하기 바란다...)
 2. *.deploy.cmd를 적절한 인자를 주어 실행해야 한다. 사용한 batch 파일은 아래와 같다. 
 
 ```
 @echo off

 set path=%path%;C:\Program Files\IIS\Microsoft Web Deploy V3

 xcopy Nv.WebUI.SetParameters.nv.dev.xml Nv.WebUI.SetParameters.xml /y
 Nv.WebUI.deploy.cmd /Y /M:http://hiscale2/MSDeployAgentService /u:dev\hiscale /P:unreal!1 "-enableRule:Donotdeleterule" > log.nv.dev.txt
 ```

## 웹 반응속도를 위한 설정 변경
- iis 관리자 > 응용 프로그램 풀 > 사용하는 풀 선택 후 우클릭 '고급설정'
 일반 > 시작모드를 OnDemand -> AlwaysRunning
 재생 > 표준 시간 간격(분)을 1740 -> 0
 프로세스 모델 > 유휴 시간 제한(분)을 20 -> 0

