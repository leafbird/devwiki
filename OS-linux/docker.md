## 이미지 버전 업데이트하기 

https://ma.ttias.be/update-docker-container-latest-version/


## 이미지 파일 저장 경로 변경 

출처 : https://forums.docker.com/t/where-are-images-stored/9794

`docker info` 쳐보면 기본으로 image가 생성되는 경로는 `C:\ProgramData\Docker` 이다. 

config 설정에서 다음과 같이 변경한다. 
(한 번 이미지를 받고 나서 변경하려면 받아놓은 이미지 지우기가 쉽지 않으니 반드시 처음에 변경할 것.)
windows container에 해당하는 사항. windows contianer는 hyper-v와 충돌이 잦아 아직 불안정한 느낌이다. 

```
{
"data-root": "d:\\docker"
}
```

## docker에서 쓰던 파일이 권한 문제로 안 지워질 때 

참고 : 
- https://stackoverflow.com/questions/43588935/docker-for-windows-cleanup
- https://github.com/moby/docker-ci-zap

```
    run file:
    .\docker-ci-zap.exe -folder "C:\ProgramData\docker"
```


## 기본 명령어 정리
* docker run -i -t ubuntu:14.04 // 컨테이너 생성, 실행, 진입. (-i 상호입출력, -t tty 활성화)
* 컨테이너를 정지하며 종료 : exit 입력 혹은 Ctrl + d
* 컨테이너를 정지하지 않고 종료 : Ctrl + p, q
* docker images : 도커 엔진에 존재하는 이미지 목록 출력
* docker create -i -t --name mycentos centos:7 // 생성만 하고 진입하지 않음. 
* docker start mycentos // 컨테이너 시작
* docker attach mycentos // 컨테이너 내부로 진입
* docker ps // 정지되지 않은 컨테이너 출력 
* docker ps -a // 정지된 컨테이너를 포함한 모든 컨테이너 출력
* docker inspect mycentos | grep id // 컨테이너 정보 확인
* docker rename angry_morse my_container // 컨테이너 이름 변경
* docker rm angry_morse // 컨테이너 삭제. 실행중이지 않을 때만 삭제 가능
* docker stop mycentos // 컨테이너 정지. 
* docker rm -f mycentos // 실행중인 컨테이너 삭제. 
* docker container prune // 모든 컨테이너 삭제. 
* docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) // 모든 컨테이너 정지 및 삭제
* docker run -i -t --name mywebserver -p 80:80 ubuntu:14.04 // 포트 바인딩

## 명령어 활용 

* -i, -t, -d 옵션을 함께 사용하면 컨테이너 내부에서 셸을 생성하지만 내부로 들어가지 않으며 컨테이너도 종료되지 않음. 테스트용 컨테이너를 생성할 때 유용. 
    create -i -t로 생성 먼저 하고 start로 시작하는 두 단계를 한 번에 하는 효과.

* 비 대화형으로 생성한 컨테이너에 쉘 오픈하기
    % docker exec -t -i wordpress /bin/bash


## 명령어 예시
    wordpress를 db와 web 두 개의 컨테이너로 구성하기 
    
    % docker run -d \
    --name wordpressdb \
    -e MYSQL_ROOT_PASSWORD=password \
    -e MYSQL_DATABASE=wordpress 
    mysql:5.7
    
    % docker run -d \
    -e WORDPRESS_DB_PASSWORD=password \
    --name wordpress \
    --link wordpressdb:mysql \
    -p 80 w\
    ordpress

## 볼륨 활용

1. 호스트와 볼륨 공유 (파일도 가능. -v 여러 개 가능)
2. 볼륨 컨테이너 활용 (-v 옵션으로 볼륨을 사용하는 컨테이너를 다른 컨테이너와 공유)
3. 도커가 관리하는 볼륨 생성 (docker volume)

### 호스트와 볼륨 공유

    % docker run -d \
    --name wordpressdb_hostvolume \
    -e MYSQL_ROOT_PASSWORD=password \
    -e MYSQL_DATABASE=wordpress 
    -v /home/wordpress_db:/var/lib/mysql \
    mysql:5.7

### 볼륨 컨테이너 : 볼륨 공유만을 담당하는 컨테이너

    % docker run -i -t \
    --name volumes_from_container \
    --volumes-from volume_overide\
    ubuntu:14.04

### 도커 볼륨 : 도커가 자체생성 & 관리하는 볼륨을 물려서 사용

    % docker volume create --name myvolume
    % docker volume ls
    % docker run -i -t --name myvolume_1 \
    -v myvolume:/root/ \
    ubuntu:14.04


## 도커 네트워크 (bridge, host, none)

    % docker network ls
    % docker network inspect bridge


#### 브리지 네트워크

    % docker network create --driver bridge mybridge
    % docker run -i -t --name mynetwork_contaier \
    --net mybridge \
    ubuntu:14.04

    % docker network create --driver=bridge \
    --subnet=172.72.0.0/16 \
    --ip-range=172.72.0.0/24 \
    --gateway=172.72.0.1 \
    my_custom_network

#### 호스트 네트워크 
* --net host 옵션으로 설정
* 호스트의 네트워크 환경을 그대로 쓴다.  

#### 논 네트워크
* --net none
* 아무런 네트워크를 쓰지 않는다. 

#### 컨테이너 네트워크
* --net container:network_container_1
* 다른 컨테이너의 네트워크 환경을 공유. 내부ip, mac address 등.

### 브릿지 네트워크 내부 DNS 이용해서 load balancer 효과 내기

    % docker network create --driver bridge mybridge // 브릿지 네트워크 만든다. 
    % docker run -i -t -d --name xxx1 --net mybridge --net-alias alicek106 ubuntu:14.04 // 만든 네트워크 붙이고, alias 지정. 
    % docker run -i -t -d --name xxx2 --net mybridge --net-alias alicek106 ubuntu:14.04 // 만든 네트워크 붙이고, alias 지정. 
    % docker run -i -t -d --name xxx3 --net mybridge --net-alias alicek106 ubuntu:14.04 // 만든 네트워크 붙이고, alias 지정. 
    % docker run -i -t --name xxx_ping --net bridge ubuntu:14.04 // 확인용
    # ping -c 1 alicek106 // 반복 실행. ip 변경 확인. 
    # apt update && apt install -y dnsutils 
    # dig alicek106 // 목록 확인

## 로그 

    % docker logs mysql // 이름이 mysql인 컨테이너의 로그 확인
    % docker logs --tail 2 mysql // tail 2줄만 확인
    % docker logs -f -t mysql // f로 스트림 출력, t로 시간 출력 

로그는 아래 경로에 json 형태로 저장된다.

    # cat /var/lib/docker/containers/${CONTAINER_ID}/${CONTAINER_ID}-json.log

기본 드라이버 외에 추라 출력 수단을 제공한다 : syslog, journalid, fluentd, awslogs
도커 데몬 시작할 때 기본 드라이버 변경 가능 `DOCKER_OPTS="--log-driver=syslog"`
개별 컨테이너 단위로 변경할 땐 `--log-driver=syslog` 처럼 인자 지정

### 컨테이너 자원 할당 제한

    # docker update (변경할 자원 제한) (컨테이너 이름)
    # docker update --cpuset-cpus=1 centos ubuntu
    # docker run -d --memory="1g" --name memory_1g nginx
    # docker run -it --name swap_500m --memory=200m --memory-swap=500m ubuntu:14.04
    # docker run -it --name cpu_share --cpu-shares 2048 ubuntu:14.04 // 기본값 1024 (cpu 할당에서 1의 비율. 2048이면 2배.)
    ... 이하부터 설명 생략..
    --cpuset-cpu
    --cpu-period, --cpu-quota
    --cpus
    --device-write-bps
    --device-read-bps
    --device-write-iops
    --device-read-iops


## 도커 이미지

검색 : docker search (keyword)
컨테이너를 이미지로 만들기 : docker commit

## 사용중인 컨테이너 이미지 백업 및 복원

https://bluedayj.tistory.com/70 

## 실행중인 컨테이너의 환경변수를 바꾸고 싶을 때

```
docker commit gitlab gitlab:200827
docker stop gitlab
docker container prune
docker run ..... gitlab:200827
```

## run할 때 -e로 넣어준 환경변수를 변경하기
https://11q.kr/g5s/bbs/board.php?bo_table=s11&wr_id=8867
```
docker inspect xxxx # container id 알아내기
docker stop xxxx
systemctl stop docker # 반드시 docker를 끈 상태로 수정해야 함.
vi /var/lib/docker/containers/{container-id}/config.v2.json # config 파일 변경.
systemctl start docker
docker start xxxx
```

## 도커 이미지 저장 위치 
출처 : https://github.com/microsoft/WSL/issues/4176

    From linux: sudo ls /mnt/wsl/docker-desktop-data/data/docker/volumes
    From windows: \\wsl$\docker-desktop-data\mnt\wsl\docker-desktop-data\data\docker\volumes

    it might be in in a VHDX file in C:\Users\_user_\AppData\Local\Docker\wsl\data

## 에러 해결 
 max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
 docker for windows, wsl2 모드에서 아래처럼 조정

 출처 : https://github.com/docker/for-win/issues/5202

```
❯ wsl --shutdown # because we don't really need to restart the computer to see the config is lost ...
❯ wsl -d docker-desktop cat /proc/sys/vm/max_map_count # current value
65530
❯ wsl -d docker-desktop sysctl -w vm.max_map_count=262144
vm.max_map_count = 262144
❯ wsl -d docker-desktop cat /proc/sys/vm/max_map_count 
262144
❯
```

vm.max_map_count을 영구적으로 설정하기.

```
    sudo -i # 아예 root로 전환
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    exit # root 종료
    sudo sysctl --system # 설정 되었는지 확인    
```

## 사설 레지스트리 구축하기
https://nirsa.tistory.com/74
https://github.com/docker/distribution-library-image/issues/89
```
# 레지스트리로 사용할 장비. 현재 리눅스만 지원.
# (현재 registry 2.7 버전에 버그 있는 듯.)
docker run -d -p 5000:5000 --name registry -e REGISTRY_VALIDATION_DISABLED=true registry:2

#배포할 장비.
docker image tag leafbird/counterside 192.168.0.7:5000/counterside # 기존 이미지에 tag 추가.
docker image push 192.168.0.7:5000/counterside


# Docker Private Registry 이미지 리스트확인
curl -X GET http://localhost:5000/v2/_catalog
curl -X GET http://localhost:5000/v2/counterside/tags/list
Invoke-RestMethod -Method get -uri http://192.168.0.7:5000/v2/_catalog
Invoke-RestMethod -Method get -uri http://192.168.0.7:5000/v2/counterside/tags/list

```

### 사설 레지스트리 이슈 해결

`http: server gave HTTP response to HTTPS client` 발생 시
https://www.leafcats.com/200

docker for windows 같은 경우 dashboard열어서 설정창에 insecure-registries 넣어준다. 
```
{
  "registry-mirrors": [],
  "insecure-registries": ["192.168.0.7:5000"],
  "debug": false,
  "experimental": false
}
```

## 로그 rotate

출처 : http://egloos.zum.com/mcchae/v/11259352

리눅스에서 Docker 로 컨테이너를 구성하고 컨테이너의 STDOUT 내용은
/var/lib/docker/containers/*/*.log 라는 이름으로 저장됩니다.

문제는 특별한 조치를 취하지 않으면 계속해서 해당 로그 파일에 큰 로그 파일이 찰 수 밖에
없는 것이지요.

이것을 logrotate 기능을 이용하는 방법입니다.

```
$ sudo vi /etc/logrotate.d/docker-container
/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  size=1M
  missingok
  delaycompress
  copytruncate
}
```

위와 같이 docker 컨테이너의 로그를 위한 설정을 지정합니다.

rotate 7 : 최대 log.1, log.2 등 7개의 파일을 보관하고
daily : 날마다 rotate 시키며
compress : 이전 로그는 압축하며
size=1M : 크기가 1메가 바이트를 넘으면 로테이트,
missingok : 해당 로그가 없어도 ok,
delaycompress : 
copytruncate : 복사본을 만들고 크기를 0으로 

라고 설정합니다.

현재 로그를 우선 적용해 보려면

    $ sudo logrotate -fv /etc/logrotate.d/docker-container

라고 하면 됩니다.