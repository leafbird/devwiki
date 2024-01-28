### 이벤트 수신용 봇을 위한 설정

기존에 있던 RTM API (realtime api) 는 사용은 가능하지만 deprecated 되었다. 대신 socketMode를 제공하므로 신규 개발 앱은 이를 사용하는 것이 좋다. 

#### 주요 설정

참고 : https://github.com/soxtoby/SlackNet/tree/master/Examples/SlackNetDemo

1. https://api.slack.com/apps 이동. 신규 앱 생성
2. 왼쪽 메뉴 `OAuth & Permission` 선택하고 
	`users:read` `channels:read` `groups:read` `im:read` `mpim:read` 권한 추가. 
	글을 쓰게 하려면 `chat:write` 추가
3. 소켓모드 활성화. 왼쪽 메뉴 `Socket Mode`. 활성하면 App-Level Token이라는 추가적인 토큰을 받는다. 왼쪽 메뉴 `Basic Information` 에서 확인 가능하다. 
4. `Enable the home tab` 기능 활성화... 는 꼭 필수까진 아닌듯..
5. [중요] 이벤트를 활성화. `Basic Information` > Add Features and functionality > Event Subscriptions 선택하면 활성 여부 컨트롤이 나온다. 
6. 위 활성 설정하는 페이지와 동일한 곳에서 권한 추가. 
	`app_home_opened` 홈탭 보여주기 위한 권한
	`message.channels` `message.groups` `message.im` `message.mpim` 메시지 이벤트 수신 권한
7. 이벤트를 수신하고자 하는 채널에 앱을 설치. 각 채널의 설정 메뉴에서 진행. 

#### 봇이 쓰는 메세지의 아이콘과 유저이름을 변경하고 싶을 때

참고 : https://api.slack.com/methods/chat.postMessage

클래식 앱과 이후의 앱이 방식이 다름. https://api.slack.com/methods/chat.postMessage#authorship 섹션 확인
결론 : 추가 권한 `chat:write.customize` 넣어주고 username이랑 icon_emoji 사용하면 된다. 