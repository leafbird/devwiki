## CORS 에러

cors에 대한 기본을 공부하려면 : https://developer.mozilla.org/ko/docs/Web/HTTP/Access_control_CORS

- 요약하면, 브라우저가 요청 헤더에 직접 Origin: example.com 같은 걸 박는다. 플러그인에서 쏘는 요청엔 Origin: null을 박는다. 
- 서버에서는 response 헤더에 승인 여부를 알려온다. Access-Control-Allow-Origin: XXXX 같은거다. 
- 그래서 서버쪽에서 승인할 origin 리스트를 설정해 주어야 한다.

### 팀시티 rest api 사용할 떄 CORS 에러 트러블 슈팅

팀시티 매뉴얼에 CORS에 대해 소개되어 있다. 

- https://confluence.jetbrains.com/display/TCD9/REST+API#RESTAPI-CORSSupport

2018.2 버전까지는 아직 `rest.cors.origins=*` 해주면 잘 동작한다. 매뉴얼에는 * 넣지 말라고 되어있지만, 동작이 안 하지는 않음. 

guest 접근이 안 되어 있을 때, 브라우저 콘솔상에 CORS에러를 뱉는다. 팀시티 서버 로그를 열어보면 guest 접근 제한 문제인지 알 수 있는데,

```
[2018-12-15 22:44:24,906]   WARN -     jetbrains.buildServer.AUTH - HTTP login failed with message: "Guest user login is disabled", user message: "An error in configuration or an internal error occurred during login. Please contact your system administrator.", request: GET '/guestAuth/app/rest/buildTypes?fields=buildType%28id%2CprojectName%2Cname%2Cbuilds%28%24locator%28running%3Afalse%2Ccanceled%3Afalse%2Ccount%3A1%29%2Cbuild%28number%2Cstatus%2CfinishDate%29%29%29', from client [0:0:0:0:0:0:0:1]:51886, no auth: jetbrains.buildServer.serverSide.auth.AuthenticationFailedException: Guest user login is disabled (enable debug to see stacktrace)
```

이것도 서버에 로그파일이 많은데 `teamcity-rest.log`에서 찾으면 안되고 `teamcity-server.log`에서 찾아야 함. 겁나 헤맸네... 