# Install Arch Linux on MBR partition

proxmox에서 vm으로 arch linux 설치 하는 과정을 정리합니다. 기본 bios인 seabios를 이용해 MBR 파티션으로 설치합니다.

참고 : https://medium.com/@sydasif78/arch-linux-installation-virtual-machine-a188d028359

```sh
passwd # root 비밀번호 설정
ip a # ip 확인 후, ssh 원격 접속 후 진행
```

## 파티션 분할

```sh
fdisk -l # 파티션 타입 확인
lsblk -f # 파티션 레이블 확인

fdisk /dev/sda # 파티션 생성
p # 현재 파티션 확인
d # (반복) 기존 파티션 모두 삭제. 파티션 번호는 디폴트로 하나씩 선택된다.
p # 모든 파티션이 삭제된 것을 확인

o # create a new empty MBR (DOS) partition table
  # gpt signature가 남아있다는 경고가 나올 수 있으나 동작에 문제는 없음. 이어서 진행한다.

n # add a new partition
p # primary partition
1 # partition number
(엔터) # first sector는 자동으로 맡기세요
-4G # 다음 파티션 공간을 위해 4G를 남겨둡니다.

n # add a new partition
p # primary partition
2 # partition number
(엔터) # first sector는 자동으로 맡기세요
(엔터) # last sector는 자동으로 맡기세요

# 스왑 파티션 타입 설정
t # change a partition's system id
2 # partition number    
82 # Linux swap / Solaris

p # partition table 확인
  # /dev/sda1 : Linux (루트 파티션)
  # /dev/sda2 : Linux swap (스왑 파티션)

w # write the partition table to disk

fdisk -l # 파티션 확인
```


## 파일 시스템 생성, 마운트

```sh
lsblk -f

NAME   FSTYPE   FSVER            LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0  squashfs 4.0                                                                     0   100% /run/archiso/airootfs
sda
├─sda1
└─sda2
sr0    iso9660  Joliet Extension ARCH_202504 2025-04-01-14-28-13-00                     0   100% /run/archiso/bootmnt

mkfs.ext4 /dev/sda1 # ext4 파일 시스템 생성
mkswap /dev/sda2

lsblk -f
NAME   FSTYPE   FSVER            LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0  squashfs 4.0                                                                     0   100% /run/archiso/airootfs
sda
├─sda1 ext4     1.0                          ce282113-1e96-4b5b-bab4-d486056445bf
└─sda2 swap     1                            7f9750d7-db09-44d9-abd5-78c11188f0c0                [SWAP]
sr0    iso9660  Joliet Extension ARCH_202504 2025-04-01-14-28-13-00                     0   100% /run/archiso/bootmnt
```


스왑 파티션 활성화.
```sh
swapon /dev/sda2
swapon --show
```

마운트
```sh
mount /dev/sda1 /mnt
mkdir /mnt/home
mkdir /mnt/etc
lsblk -f # 마운트 확인
```

## 베이스 시스템 설치 및 설정

빠른 설치를 위해 reflector 설치
```sh
pacman -Syy reflector
cp /etc/pacman.d/mirrorlist{,.bak}
reflector -c "KR" -f 7 -l 5 -n 7 --save /etc/pacman.d/mirrorlist
# -c : 국가
# -f : 최신 미러 7개를 가져옴
# -l : 5시간 이내에 업데이트된 미러
# -n : 7개 미러를 가져옴
# --save : /etc/pacman.d/mirrorlist에 저장
```

```sh
pacstrap -K /mnt base linux linux-firmware      # 반드시 설치해야 하는 패키지입니다.
pacstrap /mnt base-devel      # AUR을 사용하는 경우 설치해야 할 수 있습니다.
pacstrap /mnt vim neovim networkmanager man-{db,pages} git # 중요한 패키지입니다.

# 부팅시 파티션 자동 마운트 설정
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# 시스템 진입
arch-chroot /mnt

# 시간대 및 로케일 설정
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc

vim /etc/locale.gen
# ko_KR, en_US 주석 해제

locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# 호스트네임 설정
echo minis13n150 > /etc/hostname

# 계정 설정
# passwd # root 비밀번호는 가장 처음에 설정했으므로 넘어갑니다.
pacman -S zsh # zsh 설치
useradd -m -G wheel -s /bin/zsh florist # 계정 생성
passwd florist # 비밀번호 설정
# visudo # wheel 그룹에 대한 sudo 권한 설정
EDITOR=vim visudo
# %wheel ALL=(ALL) ALL 주석 해제
```

## 부트로더 설치 (grub)

```sh
pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```


## 네트워크, ssh

```sh
systemctl enable NetworkManager
pacman -S openssh
systemctl enable sshd
exit
umount -R /mnt
reboot
```

성공적으로 부팅이 완료되면 나머지 개인설정은 [기존 문서](arch 설치.md) 하단 `개인설정` 부분을 참고하세요.