# Teamcity



## 한 머신에 에이전트 추가하기

https://www.jetbrains.com/help/teamcity/setting-up-and-running-additional-build-agents.html

#### mac에서 에이전트 설정 (공통)

* minimal zip 파일을 받는다. temcity agent 화면에서 받을 수 있다. 

* 파일 위치시키고 설정파일 준비

  ``` shell
  export AGENT_HOME=$HOME/buildAgent_ca07-1
  
  mv /Users/buildman/Downloads/buildAgent $AGENT_HOME
  
  cd $AGENT_HOME/conf
  mv buildAgent.dist.properties buildAgent.properties
  vi buildAgent.properties
  ```

* m1인 경우 homebrew 경로를 모르는 문제가 있음. 설정파일 열고 가장 아래에 한 줄 추가
  ```shell
  env.PATH=%env.PATH%:/opt/homebrew/bin
  ```
  
* 서버 주소 설정하고 이름 지정:

  ```
  serverUrl=http://clitc.bside.com
  name=agent-ca7-1
  ```

  $AGENT_HOME/launcher/conf/warpper.conf 이름 변경은 윈도우만 해주면 됨.



#### 머신에 첫 에이전트 설치인 경우

```shell
# logs 폴더를 만들고, 에이전트를 로딩한다. 에이전트가 업데이트 되길 기다린다. 
mkdir $AGENT_HOME/logs
sh $AGENT_HOME/bin/mac.launchd.sh load
tail -f $AGENT_HOME/logs/teamcity-agent.log

# 에이전트를 멈춘다
sh $AGENT_HOME/bin/mac.launchd.sh unload

# 계정 하위에 plist 위치용 폴더 생성하고 복사.
mkdir $HOME/Library/LaunchAgents
cp $AGENT_HOME/bin/jetbrains.teamcity.BuildAgent.plist $HOME/Library/LaunchAgents
vi $HOME/Library/LaunchAgents/jetbrains.teamcity.BuildAgent.plist # 아래 내용 추가 및 확인
	<key>UserName</key>
	<string>buildman</string>
	(WorkdingDirectory 항목 올바른지 확인 및 수정)

# 리붓하고 에이전트 실행 되는지 확인
sudo reboot now
launchctl list | grep BuildAgent
```



#### 머신에 추가 에이전트 설치인 경우

* 서비스(데몬?) 설정

  ```shell
  cp $HOME/Library/LaunchAgents/jetbrains.teamcity.BuildAgent.plist $HOME/Library/LaunchAgents/jetbrains.teamcity.BuildAgent2.plist
  
  vi $HOME/Library/LaunchAgents/jetbrains.teamcity.BuildAgent2.plist
  ```

  - the `Label` parameter to `jetbrains.teamcity.BuildAgent2`
  - the `WorkingDirectory` parameter to the correct path to the second build agent home

* 실행 및 실행 확인

  ```shell
  # Start the second agent with the command
  launchctl load $HOME/Library/LaunchAgents/jetbrains.teamcity.BuildAgent2.plist
  
  # To check that both build agents are running, use the following command:
  launchctl list | grep BuildAgent
  70599	0	jetbrains.teamcity.BuildAgent2
  69722	0	jetbrains.teamcity.BuildAgent
  ```

  

#### mac os에서 에이전트 서비스 관리

```shell
launchctl remove jetbrains.teamcity.BuildAgent # 서비스 중지

launchctl list | grep BuildAgent # 현재 실행중인지 확인
launchctl error 78 # 상태오류 78 추가정보 조회
```

