### 실해하려는 명령어가 없을 떄

아래 사이트에서 명령어 검색

    https://command-not-found.com/

### ping 명령어가 없을 때 (ping: command not found)

출처 : https://blog.dalso.org/it/11535

linux

	apt-get install iputils-ping

docker

	dockerfile에 내용 추가

	FROM ubuntu
	RUN apt-get update && upt-get install -y iputils-ping
	CMD bash

	다시 빌드 후 컨테이너 생성

    