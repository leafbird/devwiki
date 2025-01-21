## Linux 네트워크 관련 명령

### nslookup

* 설명: DNS(Domain Name System) 정보를 조회하는 명령어입니다. 도메인 이름에 대한 IP 주소를 확인하거나, IP 주소를 통해 도메인 이름을 확인할 때 사용합니다.
```sh
nslookup example.com
nslookup 8.8.8.8
```
추가 정보: 기본 DNS 서버를 설정하지 않았다면 /etc/resolv.conf 파일을 확인하거나 변경해야 합니다.

### dig

* 설명: DNS 조회를 수행하며, nslookup보다 더 상세한 정보를 제공합니다. 다양한 DNS 레코드 유형(A, MX, TXT 등)을 확인할 수 있습니다.

```sh
dig example.com
dig @8.8.8.8 example.com
dig example.com MX
```

옵션:
* `+short`: 간단한 결과만 출력합니다.
* `+trace`: DNS 질의 과정을 추적합니다.

### host

* 설명: 도메인 이름과 IP 주소를 간단하게 변환하거나, DNS 서버에 요청하여 특정 정보를 조회합니다.

```sh
host example.com
host 8.8.8.8
```

특징: nslookup과 비슷하지만, 간단한 결과를 빠르게 확인할 때 유용합니다.

### ping

* 설명: 네트워크 연결 상태를 확인하기 위해 특정 호스트로 패킷을 전송합니다.

```sh
ping -c 4 example.com
```

옵션:
* `-c`: 패킷 전송 횟수를 지정합니다.

### traceroute

* 설명: 특정 목적지까지 데이터가 경유하는 네트워크 경로를 확인합니다.

```sh
traceroute example.com
```

참고: 설치되지 않은 경우 sudo apt install traceroute로 설치할 수 있습니다.

### netstat (또는 ss)

* 설명: 네트워크 연결, 포트 상태, 라우팅 테이블 등을 확인합니다.

```sh
netstat -tuln
ss -tuln
```

옵션:
* `-t`: TCP 연결만 표시
* `-u`: UDP 연결만 표시
* `-l`: 수신 대기 중인 포트 표시
* `-n`: 숫자 형식으로 결과 표시

### curl

* 설명: HTTP/HTTPS 요청을 수행하고 응답을 확인할 수 있는 도구입니다.

```sh
curl -I https://example.com
curl -X POST -d "param=value" https://example.com
```

옵션:
* `-I`: HTTP 헤더만 출력
* `-X`: 요청 메서드 지정 (GET, POST 등)

### wget

* 설명: 파일을 다운로드하거나 HTTP 요청을 보낼 때 사용합니다.

```sh
wget https://example.com/file.zip
wget -r -np https://example.com
```
