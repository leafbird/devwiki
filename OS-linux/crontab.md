## crontab

## crontab.guru
참고 : https://crontab.guru/




1) cron deamon 상태 확인
ps -ef | grep cron 

2) cron deamon kill 
kill -9 "pid of cron" 

3) deamon 재실행 
/usr/sbin/cron 

4) 명령어 위치 
/usr/bin/crontab 

5) 사용형식 
crontab [ -u 사용자ID ] 파일 
crontab [ -u 사용자ID ] { -l | -r | -e } 


>> cron 설정

1) crontab 파일 위치 및 조회 
/var/spool/cron/ID
crontab 설정 편집 -e 옵션, 설정 조회 -l 옵션, 설정 삭제 -d 옵션

> 설정 조회
$ crontab -l 
no crontab for truefeel 
비어있음.

- /etc/crontab 파일 
- /etc/rc.d/init.d/crond 스크립트 
- /var/spool/cron 디렉토리 내의 크론 설정 파일들 

2) crontab 파일 형식 
----------    ----------  ---------------------------------------
필  드                의  미          범  위 
----------    ----------  ---------------------------------------
첫 번째                   분          0-59 
두 번째                   시          0-23 
세 번째                   일          0-31 
네 번째                   월          1-12 
다섯 번째             요일          0-7 (0 또는 7=일요일, 1=월, 2=화, ...) 
여섯 번째          명령어          실행할 명령을 한줄로 작성
----------    ----------  ---------------------------------------
- 모든 엔트리 필드는 공백으로 구분
- 한 줄당 하나의 명령 (두줄로 나눠서 표시할 수 없음) 
- # 으로 시작하는 줄은 실행하지 않음

> 설정 편집
$ crontab -e 
# /home 디렉토리를 /BACKUP/home으로 백업
# 
# 30분, 새벽 4시와 낮 12시, 모든 일, 모든 월, 모든 요일 
30 4,12 * * *  /usr/bin/rsync -avxH --delete /home /BACKUP/home > /dev/null 2>&1 
# 
# 파일/디렉토리 퍼미션 설정 
# 40분, 새벽 1시, 매주 일요일 
40 1 * * 0  /root/bin/perm_set.sh   > /dev/null 2>&1 

위는 매일 4:30분과 12:30분에 rsync 명령을, 매주 일요일 1:40분에 perm_set.sh를 실행함을 의미

3) 설정 예 
- '*'표시는 해당 필드의 모든 시간을 의미
- 3,5,7와 같이 콤마(,)로 구분하여 여러 시간대를 지정
- 2-10와 같이 하이픈(-)으로 시간 범위도 지정
- 2-10/3와 같이 하이픈(-)으로 시간 범위를 슬래쉬(/)로 시간 간격을 지정 (2~10시까지 3시간 간격으로. 즉, 3, 6, 9시를 의미) 

원하는 시간 -> 형  식 
매주 토요일 새벽 2:20          -> 20  2 *  *  6  명령어 
매일 오후 4,5,6시                -> 0  4-6   *  *  *  명령어 
매일 2시간 간격으로 5분대에 -> 5  */2 *  *  * 명령어 
매월 1일 새벽 1:15               -> 15  1   1  *  *  명령어 
1,7월 1일 새벽 0:30              -> 30  0   1  1,7  *  명령어 

4) /etc/crontab 파일로 설정 
매시 1회 자동실행하기 위한 시스템 cron 설정
01 * * * * root run-parts /etc/cron.hourly 
  - 매일 매시 01분마다 /etc/cron.hourly 디렉토리내에 존재하는 파일들을 실행
 
매일 1회 자동실행하기 위한 시스템 cron 설정
02 4 * * * root run-parts /etc/cron.daily 
  - 매일 새벽 4시 02분마다 /etc/cron.daily  디렉토리내에 존재하는 파일들을 실행
 
매주 1회 자동실행하기 위한 시스템 cron 설정
22 4 * * 0 root run-parts /etc/cron.weekly 
  - 매주 일요일 새벽 4시 22분마다 /etc/cron.weekly 디렉토리내에 존재하는 파일들을 실행
 
매월 1회 자동실행하기 위한 시스템 cron 설정
42 4 1 * * root run-parts /etc/cron.monthly 
  - 매월 1일 새벽 4시 42분마다 /etc/cron.monthly 디렉토리내에 존재하는 파일들을 실행
 
* root 이외의 사용자에게 crontab 명령어를 이용할 수 있게 하는 방법 
  - /etc/cron.allow 파일에 사용자의 id를 등록
 
* 일반사용자의 crontab 명령어사용을 제안하고자 한다면 
  - /etc/cron.deny 파일에 사용자의 id 를 등록 

// crontab -e 으로 설정 바로 적용됨

// cron 접근 사용자 설정
/etc/cron.allow : 허용할 사용자 ID 목록 
/etc/cron.deny : 거부할 사용자 ID 목록 
cron.allow 파일이 있으면 이 파일에 들어있는 ID만 사용 가능 
cron.deny 파일이 있으면 이 파일에 들어있는 ID는 사용 불가

" > /dev/null  2>&1 "
지정한 명령어 처리 결과와 발생할지 모르는 에러메시지를 출력하지 않고 모두 버린다는(/dev/null)는 뜻
만약 결과와 에러를 파일로 저장하려면 /dev/null 대신 파일명을 기입