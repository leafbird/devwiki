# Arch Linux 설치 및 설정

참조 : https://karupro.tistory.com/125

```sh
cat /sys/firmware/efi/fw_platform_version # 64비트 UEFI인지 확인

passwd # root 비밀번호 설정
ip a # ip 확인 후, ssh 원격 접속 후 진행
```

## 파티션 분할

```sh
fdisk -l # 파티션 타입 확인
lsblk -f # 파티션 레이블 확인

gdisk /dev/nvme0n1 # 파티션 생성
d > 4
d > 3
d > 2
d  # 1은 자동 선택됨. 기존의 파티션을 모두 삭제.
p # 모든 파티션이 삭제된 것을 확인

n       # 파티션 새로 만들기
(엔터)   # 파티션 번호를 할당하는 과정입니다
(엔터)   # 첫 섹터는 자동으로 맡기세요
+512M   # 512MB 할당
ef00    # EFI system partition 할당

n
(엔터)
(엔터)
+8G
8200    # Linux Swap 할당

n
(엔터)
(엔터)
(엔터)   # 남는 용량 전부
(엔터)   # 자동으로 알맞는 파일 시스템이 선택됨

p       # 파티션 구성 확인
w       # 디스크에 작성

(경고 메세지가 나오면 y 입력 후 엔터)
```

## 파일 시스템 생성, 마운트

```sh
lsblk -f

NAME        FSTYPE   FSVER            LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0       squashfs 4.0                                                                     0   100% /run/archiso/airootfs
sda         iso9660  Joliet Extension ARCH_202502 2025-02-01-08-29-13-00
├─sda1      iso9660  Joliet Extension ARCH_202502 2025-02-01-08-29-13-00
└─sda2      vfat     FAT32            ARCHISO_EFI 679D-DB59
nvme0n1
├─nvme0n1p1 vfat     FAT32                        A283-E3C3
├─nvme0n1p2
└─nvme0n1p3

mkfs.fat -F 32 /dev/nvme0n1p1
#mkfs.fat 4.2 (2021-01-31)

mkswap /dev/nvme0n1p2
# Setting up swapspace version 1, size = 8 GiB (8589930496 bytes)
# no label, UUID=72e5b15c-b07c-4a57-a54d-b8d0af74232d

mkfs.ext4 /dev/nvme0n1p3

mke2fs 1.47.2 (1-Jan-2025)
/dev/nvme0n1p3 contains `JavaScript source, Unicode text, UTF-8 text, with very long lines (65535), with no line terminators' data
Proceed anyway? (y,N) y
Discarding device blocks: done
Creating filesystem with 122798336 4k blocks and 30703616 inodes
Filesystem UUID: 3e0e9ca8-a105-4964-ab90-d9b5c5e245d6
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000

Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks): ---> 여기서 시간이 좀 걸린다. 
done
Writing superblocks and filesystem accounting information: done
```

파티션에 레이블 지정. 필수는 아님. 
```sh
fatlabel /dev/nvme0n1p1 "EFI"
swaplabel -L "Linux Swap" /dev/nvme0n1p2
e2label /dev/nvme0n1p3 "Arch Linux"

lsblk -f

NAME        FSTYPE   FSVER            LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0       squashfs 4.0                                                                     0   100% /run/archiso/airootfs
sda         iso9660  Joliet Extension ARCH_202502 2025-02-01-08-29-13-00
├─sda1      iso9660  Joliet Extension ARCH_202502 2025-02-01-08-29-13-00
└─sda2      vfat     FAT32            ARCHISO_EFI 679D-DB59
nvme0n1
├─nvme0n1p1 vfat     FAT32            EFI         7A58-B7EF
├─nvme0n1p2 swap     1                Linux Swap  72e5b15c-b07c-4a57-a54d-b8d0af74232d
└─nvme0n1p3 ext4     1.0              Arch Linux  3e0e9ca8-a105-4964-ab90-d9b5c5e245d6
```

스왑 파티션 활성화.
```sh
swapon /dev/nvme0n1p2
swapon --show
```

마운트
```sh
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
# mount --mkdir /dev/nvme0n1pX /mnt/home # 다른 파티션도 마운트하는 경우
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

## 부트로더 설치 (systemd-boot)

```sh
bootctl install
vim /boot/loader/loader.conf
default arch
timeout 3
editor no

pacman -Syu intel-ucode   # 인텔 CPU인 경우
#pacman -Syu amd-ucode     # AMD CPU인 경우

vim /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img # 인텔 CPU인 경우
# initrd /amd-ucode.img # AMD CPU인 경우
initrd /initramfs-linux.img
options root=PARTUUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw

# fallback entry도 생성
cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf
title Arch Linux (fallback initramfs)
linux /vmlinuz-linux
initrd /intel-ucode.img # 인텔 CPU인 경우
# initrd /amd-ucode.img # AMD CPU인 경우
initrd /initramfs-linux-fallback.img
options root=PARTUUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw

bootctl list # 부트로더 확인
```

## 네트워크, 블루투스, ssh

```sh
pacman -S bluez{,-utils}
systemctl enable NetworkManager bluetooth
pacman -S openssh
systemctl enable sshd
exit
umount -R /mnt
reboot
```

# 개인 설정

```sh
# yay 설치
git clone https://aur.archlinux.org/yay-bin
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
bash ~/.fzf/install

# utils...
sudo pacman -S zoxide fastfetch bat ripgrep fd stow btop htop eza 
sudo pacman -S yazi lazygit
sudo pacman -S net-tools # ifconfig, netstat, ...
sudo pacman -S nodejs

# dotfiles
git clone https://github.com/leafbird/dotfiles ~/dotfiles
bash ~/dotfiles/script/setup.sh

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# starship
curl -fsSL https://starship.rs/install.sh | sh

# docker 
sudo pacman -S docker
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER # docker 그룹에 추가
sudo systemctl restart docker

sudo systemctl status docker # docker 상태 확인
sudo docker run hello-world # docker 설치 확인 (sudo 빼고 실행하려면 로그아웃 후 다시 로그인 해야 함)

yay -S lazydocker # lazydocker 설치
```