## linux 하드디스크 추가 방법

https://m.blog.naver.com/kimmingul/220639741333

리눅스에서 하드디스크 추가하는 방법은 하드디스크 장착한 후 이를 mount 하는 것이다.

(하드디스크를 컴퓨터에 물리적으로 장착하는 것은 여기서 다루지 않음)



1. 관리자 권한 획득

하드디스크를 장착한 후, root 권한으로 변경한다. (su 이용하는 것이 편하다. 물론 sudo를 이용해도 무방하다)

 $ su 


2. 하드디스크 목록 확인득

현재 장착된 하드디스크 목록을 확인할 수 있다.

#  fdisk -l

  --> 여기서 /dev/sda, /dev/sdb, /dev/sdc...  이렇게 기술된 부분이 물리적인 하드디스크를 말하며, /dev/sda1 ... 등 1,2,3.. 숫자가 붙으면 각 하드디스크별 파티션이라고 보면 된다.
   --> 새 하드디스크인 경우, 파티션 구분이 안되어 있을 것이다.



3. 새로 장착한 하드디스크의 파티션 설정 & 포멧

 # fdisk /dev/sdb

Welcome to fdisk (util-linux 2.23.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
Command (m for help): n 

위에서 /dev/sdb 는 새 하드디스크를 말하며, 이는 각자에 맞게 변경해야 한다. (sda, sdc ... 일 수 있음.)

실행하면 명령어를 입력하라고 나온다.

(1) 새로운 파티션을 분할하기 위해 'n' 명령을 한다.

(2) 그러면 파티션이 extended인지, primary partition인지 선택하라고 하며, primary를 선택하기 위해 'p' 를 입력 한다.

(3) 파티션 숫자를 입력하라고 나오며, 무난하게 1이라고 입력한다.

(4) first cylinder를 입력하라고 나오는데, 그냥 엔터를 입력하면 기본값으로 된다.

(5) 그 후 last cylinder를 입력하라고 나오는데, 그냥 엔터를 입력한다.

이렇게 하면 파티션이 만들어진다.



파티션이 잘 만들어졌는지 확인하기 위해서 'p' 명령을 한다.
...

Command (m for help): p

Disk /dev/sdb: 120.0 GB, 120034123776 bytes, 234441648 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xdd2e991a

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048   234441647   117219800   83  Linux



Command (m for help): w

The partition table has been altered!

 



파티션이 만들어졌으니, 변경된 내용을 저장해야한다. 저장은 'w' 명령을 하면 된다.



이제 해당 파티션을 포멧을 해야 사용할 수 있다.

포멧에는 mkfs 명령을 이용한다. 요즘은 ext4 방식으로 포멧한다고 한다.

 # mkfs -t ext4 /dev/sdb1

...

...

Writing inode tables: done

Creating journal (4096 blocks) : done

Writing superblocks and filesystem accounting information: done

...

위에처럼 done .. done...done 3개가 정상적으로 나오면 포멧이 제대로 된 것이다.



4. 마운트 (mount)

윈도우 사용하다가 리눅스 사용하면 잘 적응안되는 부분이 바로 마운트다.

(hdd건 usb 메모리건 cdrom이건 간에 다 mount를 해야 작용하니...물론 auto-mount 하도록 설정하면 되긴 하겠지만.)



새로운 하드디스크를 어디에 사용할지에 따라 다르겠지만, 나는 /data 디렉토리에 사용하도록 하겠다.

* mkdir /data
* chmod 777 /data      <--누구나 입출력할 수 있게 권한변경
* mount /dev/sdb1 /data
* mount 

 

이제 /data 디렉토리에 파일을 저장하면 새로운 하드디스크에 저장된다.

내 컴퓨터의 전체 디렉토리 구조를 보고자 한다면 df 명령어로 확인해본다.

- df -h 






5. 영구적인 마운트

그러나 현재 상태로는 컴퓨터를 껏다가 켜게되면 mount가 풀려버리게 된다.

항상 mount가 되어 있도록 하고자 한다면 /etc/fstab 파일을 편집해줘야 한다.



/dev/sdb1    /data        ext4    defaults     1 2        이런 식으로 넣어줄 수도 있고,

UUID=f30bcefe-e166-4526-ad1c-6a84e85dca69 /data ext4    defaults        1 2   이런 식으로 넣어줄 수도 있다.



위 내용은 총 6개의 내용으로 구분되어 있는데, 그 내용은 아래와 같다.

(1) 파일시스템장치명 (file system device name)

(2) 마운트 포인트 (mount point)

(3) 파일시스템 종료 (file system type)

(4) 마운트 옵션 (mount option)

(5) Dump

(6) File sequence check option

(이에 대한 자세한 내용은 본 글 맨 마지막에 별첨으로 붙인다.)



각자 취향에 맞게 하면 되는데, 개인적으로 UUID 가 보다 낫지 않나 싶다.

왜냐하면 sda, sdb ... 이런 이름은 차후에 하드디스크를 추가하게 되었을 때, 변경될 수도 있기 때문이다.



blkid 명령어를 이용하여 UUID 값을 확인해볼 수 있다. (또는  ls -l /dev/disk/by-uuid  )


 # blkid

/dev/sdb1: UUID="f30bcefe-e166-4526-ad1c-6a84e85dca69" TYPE="ext4"
/dev/sda1: LABEL="BACKUP_HDD" UUID="42727A85727A7E0B" TYPE="ntfs"
/dev/sdc1: SEC_TYPE="msdos" UUID="5535-964C" TYPE="vfat" PARTLABEL="EFI System Partition" PARTUUID="343f3a51-76c4-4bdb-a670-b31e847957ee"
/dev/sdc2: UUID="8a52c716-a0cd-4d9c-b4e9-486c447b194b" TYPE="xfs" PARTUUID="e31366f9-ba5f-48b6-bf97-21de8d9b5f4e"
/dev/sdc3: UUID="E2ZSnW-BcVq-93xx-6onH-U9wH-zJNt-tcNdqg" TYPE="LVM2_member" PARTUUID="37802b1b-a01c-464d-b078-8b4c8291092b"
/dev/sdd1: LABEL="DATA2" UUID="F80C4FB30C4F6C26" TYPE="ntfs"
/dev/sdd5: LABEL="DATA3" UUID="8A04083C04082DAF" TYPE="ntfs"
/dev/sde1: LABEL="DATA" UUID="980064BC0064A34C" TYPE="ntfs"
/dev/mapper/centos-root: UUID="7b2692bc-db43-4acd-a912-8a0014b48082" TYPE="xfs"
/dev/mapper/centos-swap: UUID="f66c94cb-c3e9-4e23-8b27-7a101a32be93" TYPE="swap"
/dev/mapper/centos-home: UUID="391f4e57-5e01-4d84-b036-e50e5ca4a1cf" TYPE="xfs"




이제 /etc/fstab를 편집한다.

 # vi /etc/fstab

-----아래는 vi 편집화면 내용----
```
#
# /etc/fstab
# Created by anaconda on Sun Feb 14 21:38:44 2016
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=8a52c716-a0cd-4d9c-b4e9-486c447b194b /boot                   xfs     defaults        0 0
UUID=5535-964C          /boot/efi               vfat    umask=0077,shortname=winnt 0 0
UUID=f30bcefe-e166-4526-ad1c-6a84e85dca69 /data ext4    defaults        1 2
/dev/mapper/centos-home /home                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
```



이제 새롭게 추가한 하드디스크를 마음껏 사용해보자.





---

별첨 1. /etc/fstab 의 내용  (참고: http://movenpick.tistory.com/34)

 

1.FileSystem Device Name(파일시스템장치명) 

파일시스템장치명은 곧 파티션들의 위치를 말합니다. 위에 fdisk -l를 처서 나온 부분을 보시면 /dev/sdb1~6까지의 파티션장치의 위치 즉, 주소를 나타내는것이 보일겁니다.

이러한 장치면을 써주는 필드입니다. 그대로 /dev/sdb1이런식으로 쓸수도있지만

라벨(Label)을 이용해서도 사용 가능합니다. 다른 항목들 소개후 라벨과 장치명 모두 사용하는 예를 들어보도록 할께요.



2.Mount Point(마운트포인트)

등록할 파티션을 어디에 위치한 디렉토리에 연결할것인지 설정하는 필드입니다.

마운트 시켜줄 디렉토리 경로를 써주시면되요.



3.FileSystem Type(파일시스템 종류)

파티션 생성시 정해줬떤 파일시스템의 종류를 써주는 필드입니다. 저희는 ext3으로 파일시스템을 설정하였기때문에 ext3을써줘야 합니다. 일단 파일시스템은 무슨 종류들이 있는지 소개해드리도록 할께요.



ext         -초기 리눅스에서 사용하였던 종류, 현재는 사용하지 않습니다.

ext2       -현재도 사용하며, 긴~파일시스템이름을 지원하는것이 특징입니다.

ext3       -저널링 파일시스템, ext2보다 파일시스템의 복수/보안기능을 크게향상되었고     

  현재 기본 파일시스템으로 쓰이고 있습니다.

ext4       -16TB까지만 지원하던 ext3과 달리 더큰 용량을 지원하며, 삭제된 파일 복구, 

  파일 시스템 점검속도가 훨~씬 빨라진 파일시스템입니다.

iso9660   -DVD/CD-ROM을 위한 표준 파일시스템으로 읽기만 가능합니다.

nfs         -원격서버에서 파일시스템 마운트할때 사용하는 시스템(Network File System)

swap     -스왑파일시스템, 스왑공간으로 사용되는 파일시스템에 사용합니다.

ufs        -Unix system에서 표준 파일시스템으로 사용합니다.(Unix File System)

vfat        -윈도우95/98등등 ntfs를 지원하기위한 파일시스템에 사용합니다.

msdos    -MS-DOS파티션을 사용하기위한 파일시스템에 사용합니다.

ntfs        -윈도우NT/2000의 nfts를 지원하기위한 파일시스템에 사용합니다.

hfs        -MAC컴퓨터의 hfs를 지원하기위한 파일시스템에 사용합니다.

hpfs      -hpfs를 지원하기위한 파일시스템에 사용합니다.

sysv      -Unix system v를 지원하기위한 파일시스템에 사용합니다.

ramdisk   -RAM을 지원하기위한 파일시스템에 사용합니다.



4.Mount Option(마운트옵션)

파일시스템에 맞게 사용되는 옵션들을 설정하는 필드입니다.

옵션들의 종류들부터 소개해드리도록 할께요.



default -    rw, nouser, auto, exec, suid속성을 모두 설정

auto    -    부팅시 자동마운트

noauto    -    부팅시 자동마운트를 하지않음

exec    -    실행파일이 실행되는것을 허용

noexec    -    실행파일이 실행되는것을 불허용

suid    -    SetUID, SetGID 사용을 허용

nosuid    -    SetUID, SetGID 사용을 불허용

ro    -    읽기전용의 파일시스템으로 설정

rw    -    읽시/쓰기전용의 파일시스템으로 설정

user    -    일반사용자 마운트 가능

nouser    -    일반사용자 마운트불가능, root만 가능

quota    -    Quota설정이 가능

noquota    -    Quota설정이 불가능



5.Dump

덤프(백업)가 되어야 하는지 설정하는 필드입니다.

덤프 옵션은 0과 1만 존재합니다.



0    -    덤프가 불가능하게 설정

1    -    덤프가 가능하게 설정



6.File Sequence Check Option

fsck에 의한 무결성 검사 우선순위를 정하는 옵션입니다.

0,1,2 총 3가지 옵션이 존재합니다.



0    -    무결성 검사를 하지 않습니다.

1    -    우선순위 1위를 뜻하며, 대부분 루트부분에 설정을 해놓습니다.

2    -    우선순위 2위를 뜻하며, 1위를 검사한후 2위를 검사합니다.

대부북 루트부분이 1이기때문에 루트부분 검사후 검사합니다.


#리눅스
#파티션
#하드디스크

## ubuntu 추가 하드디스크 마운트 방법
https://seongkyun.github.io/others/2019/03/05/hdd_mnt/


우분투가 설치된 하드디스크 외 추가 하드디스크 마운트 하는 방법에 대해 설명한다.

1. 하드디스크 설치
사용하는 PC에 하드디스크를 설치한다.
PC를 킨 후 sudo fdisk -l로 잘 설치 되었나 확인
새로 설치한 하드가 sda, sdb, sdc, … 어떤것인지 확인해 둠
본 글에선 sdc로 설명하며, 현재 넘버링에 따라 해당 글자만 바꾸면 됨

2. 하드디스크 용량이 2TB 이상인 경우
sudo parted /dev/sdc 입력
mklabel 입력 후 gpt
내부 데이터가 모두 사라진다는 메세지가 출력 됨
yes 입력
unit GB 입력하여 단뒤 변환
print 입력하여 용량 확인
mkpart primary 0GB 3001GB 입력(우측엔 본인 용량 입력하면 됨)
q 입력하여 커맨드로 돌아옴

3. 하드디스크 용량이 2TB 미만인 경우
sudo fdisk /dev/sdc 입력
커맨드 입력 순서는 다음과 같음
image from https://psychoria.tistory.com/521

4. 파티션 포맷
mkfs.ext4 /dev/sdc1
중간에 정보 입력하는 부분은 그냥 엔터 쳐서 무시하고 넘어가도 됨

5. UUID 확인
sudo blkid 입력하여 UUID 확인 후 복사해두기

6. 마운트
sudo mkdir /hdd_ext/hdd3000 로 외부 하드디스크 마운트 할 디렉터리 생성
sudo vim /etc/fstab로 마운트 정보 추가 및 부팅 시 자동 마운트 설정
UUID=583eb4bb-6f91-4634-b6f3-088157ae2010 /hdd_ext/hdd3000 ext4 defaults 0 0 맨 아랫줄에 입력
입력 후 :wq로 저장 후 빠져나오기
sudo mount -a로 마운트
df -h로 마운트 확인
마운트가 잘 되었으면 마운팅 된 하드디스크 정보가 보임
7. 마운팅 하드 심볼릭 링크 설정 (Symbolic link)
일종의 바로가기 개념
sudo ln -s /hdd_ext /home/han/hdd_ext로 /hdd_ext를 홈 디렉터리에 바로가기 만들어줌
cd ~/hdd_ext로 이동
sudo chmod 777 hdd3000으로 읽기 쓰기 권한 줌
링크 만들어진 폴더에 touch test.txt, sudo rm test.txt로 파일 생성이 문제없이 되는가 확인하기