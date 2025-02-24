## busybox

### dotfiles 설정

.profile 파일은 github/dotfiles에 만들어 두었다. 

CLI(command line interface)모드로 접근할 때, root나 leafbird로 할 수 있는데, leafbird로 접속한 경우 권한이 모자라 작업이 불가능한 경우가 있다. 또 기본적으로 root 이외 계정은 접근 안되도록 설정되어있음. 이를 해제하는 방법은 아래에 별도로 정리한다. 

root 접근을 기준으로 할 때, /root가 개인 폴더(~)가 된다. 이곳에 dotfiles를 설치하고, script/setup_busybox.sh를 실행하면 된다.

    > cd ~
    > git clone https://github.com/leafbird/dotfiels.git
    > cd ./dotfiles/script/
    > sh setup_busybox.sh

### ipkg 설치

참고 : http://forum.synology.com/wiki/index.php/Overview_on_modifying_the_Synology_Server,_bootstrap,_ipkg_etc#How_to_install_ipkg

 * http://forum.synology.com/wiki/index.php/What_kind_of_CPU_does_my_NAS_have 에서 cpu의 종류를 알아낸다.
 DS213+는 Freescale QorIQ P1022 ppc이다.
 * 해당 cpu model에 맞는 bootstrap를 다운받는다. 
 For 8543 PPC models http://ipkg.nslu2-linux.org/feeds/optware/syno-e500/cross/unstable/syno-e500-bootstrap_1.2-7_powerpc.xsh
 * 설치 안내를 따라 진행한다. temp 폴더로 이동해서 bootstrap를 다운받아 실행시키고, 필요없어진 bootstrap를 삭제하는 절차. 
 * PATH 환경변수를 확인해야 한다. /opt/bin, /opt/sbin이 들어있어야 하는데, 만약에 없다면 /etc/profile에 넣자. 

    > cd /etc
    > vi profile
    
    PATH=/opt/bin:/opt/sbin:$PATH 추가

### ipkg 설치 2회차 - 2025. 2. 24

gpt의 도움으로 쉽게 설치했다. script 주소는 이전의 것을 사용
```sh
wget http://ipkg.nslu2-linux.org/feeds/optware/syno-e500/cross/unstable/syno-e500-bootstrap_1.2-7_powerpc.xsh -O /tmp/bootstrap.sh
sudo sh /tmp/bootstrap.sh

# PATH 설정
echo 'export PATH=/opt/bin:/opt/sbin:$PATH' >> ~/.profile
echo 'export LD_LIBRARY_PATH=/opt/lib:$LD_LIBRARY_PATH' >> ~/.profile
source ~/.profile

# 목록 업데이트
sudo ipkg update
sudo ipkg upgrade
```

### vim 설치

ipkg를 이용해서 설치한다. 

    ipkg install vim

설치만 하면 .profile에서 alias를 설정하기 때문에 vi를 입력해도 vim이 실행된다. 

### ipkg 삭제

참고 : http://forum.synology.com/enu/viewtopic.php?f=40&t=62961

간단하게는 /volume1/@optware 폴더만 지우면 되는 듯. 그 밖에 위에서 설정한 PATH라던가.. 하는 것들은 정리 해도 되고, 놔둬도 되고.

    rm -rf /volume1/@optware

### root가 아닌 계정의 접속 허용 설정

참고 : http://bernhard.hensler.net/2008/07/17/synology-enable-ssh-user-login-other-than-root/

passwd 파일을 수정해 주어야 한다. 이곳에 home path나 사용할 shell종류 등을 설정하는데, 여기 csh로 된 것을 ash로 수정해준다. 