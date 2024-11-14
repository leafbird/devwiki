## linux 기본 명령어

## 리눅스 배포판 이름 확인하는 명령 

	grep . /etc/issue*

## cpu / 메모리 사용량 확인 

- 참고 : https://ironmask.net/355

* top
* htop
* ps aux

### 디스크 사용량 확인 : df -h
- 참고 : https://ra2kstar.tistory.com/135

* df : 디스크의 남은 용량을 확인
* du : 현재 디렉토리에서 서브디렉토리까지의 사용량을 확인
	
	du -h --max-depth=1 | sort -hr
	du -hd1 | sort -hr

디스크 정보 확인
	sudo fdisk -l | grep Disk
	lshw -class disk

### 파일 검색

출처 : https://stackoverflow.com/questions/5905054/how-can-i-recursively-find-all-files-in-current-and-subfolders-based-on-wildcard

	find . -name "foo*" // 현재 하위 경로에서 파일 찾기 

	find /home -name "*.c" 2>/dev/null

대소문자 상관없이 검색하려면 : -name 대신 -iname 사용
결과에서 permission denied를 제거하려면 : 2>/dev/null 추가

	$ find / -name 'to_be_searched.file' 2>/dev/null

### 데몬이 실행중인지 확인하기

- https://www.unix.com/unix-for-dummies-questions-and-answers/6017-check-if-deamons-running.html

	ps -ef | grep teamcity

### 로그파일 tailing하기 

	tail -f 20 buildAgent/logs/teamcity-agent.log

### 파일 복사

출처 : https://gracefulprograming.tistory.com/80

ex) source 디렉토리 내의 파일과 하위의 모든 디렉토리와 파일을 dest 통째로 복사

	cp -r source/ dest/
	(source 디렉토리를 dest로 통째로 복사)



ex) 대상 경로에 존재하지 않는 파일이나 복사하려는 파일이 더 최신인 경우에만 복사 (업데이트)

	cp -r -u source/ dest/

## netstat 설치하기

    apt update && apt install net-tools

## 리눅스 버전 알아보기

    uname -a
    or
    grep . /etc/issue*
	(centos) cat /etc/redhat-release

## 방화벽 포트 설정

To list all IPv4 rules :
	sudo iptables -S

To list all IPv6 rules :
	sudo ip6tables -S

To list all tables rules :
	sudo iptables -L -v -n | more

To list all rules for INPUT tables :
	sudo iptables -L INPUT -v -n
	sudo iptables -S INPUT

TCP 포트 허용
	sudo iptables -I INPUT 1 -p tcp --dport 8126 -j ACCEPT

설정 삭제
	sudo iptables -L INPUT --line-numbers # 라인 넘버와 함께 목록 확인 
	sudo iptables -D INPUT 2

## 쉘 스크립트를 데몬으로 만들어 실행하기

https://qastack.kr/unix/426862/proper-way-to-run-shell-script-as-a-daemon

systemd 를 사용 하면 간단한 단위를 만들어 스크립트를 데몬으로 실행할 수 있어야합니다. 많은 다른 옵션이 있습니다추가 할 수 이 있지만 이는 가능한 한 간단합니다.

스크립트가 있다고 가정 해보십시오 /usr/bin/mydaemon.

```
#!/bin/sh

while true; do
  date;
  sleep 60;
done
```
단위를 만듭니다 /etc/systemd/system/mydaemon.service.

```
[Unit]
Description=My daemon

[Service]
ExecStart=/usr/bin/mydaemon
Restart=on-failure

[Install]
WantedBy=multi-user.target 
```

당신이 실행하는 데몬을 시작하려면

	systemctl start unity-cache-server.service 

부팅시 시작하려면 활성화하십시오

	systemctl enable unity-cache-server.service

## 데몬으로 실행중인 프로세스의 로그 확인

```
ls /etc/systemd/system/ # 데몬 종류들 확인
sudo journalctl --unit=unity-cache-server # unity-cache-server.service의 로그
sudo journalctl -n 100 --unit=unity-cache-server # 마지막 로그 보기
sudo journalctl -f --unit=unity-cache-server # realtime
tail --lines=100 /var/log/syslog # stdout은 아닌거 같고, 여기에도 동작에 관한? 로그가 있음.

sudo journalctl -n 50 --unit=unity-cache-server # 최근 50줄만 보기
```

## cron에 작업 설정

참고 : https://jhnyang.tistory.com/68

```
$ journalctl -u cron.service -f # 한쪽 창에 cron 로그를 스트리밍 해둠.
$ sudo crontab -u root -e # 다른 창에서 cron 설정.
	0 0 * * * unity-cache-server-cleanup --delete >> /var/log/unity-cache-cleanup.log 2>&1
$ sudo crontab -u root -l # 적용사항 확인
$ cat /var/log/unity-cache-cleanup.log # 수행 내역 확인
$ tail -n 10 /var/log/unity-cache-cleanup.log # 수행 내역 최근 것만 확인
```