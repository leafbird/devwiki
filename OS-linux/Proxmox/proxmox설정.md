## 새로운 사용자 추가

```sh
adduser florist # 사용자 추가
usermod -aG sudo florist # sudo 권한 부여

su - florist # 사용자 변경
sudo ls /root # 동작 테스트
```

## root의 shell을 변경할 때 오류나는 경우 

```sh
root@pve:~# chsh -s $(which zsh)
Password:
chsh: PAM: Authentication failure
root@pve:~#
```

이런 경우에는 `/etc/passwd` 파일을 수정해야 합니다. 

```sh
root@pve:~# nano /etc/passwd
```

## hostname 변경

3가지 파일을 수정해야 한다.

```sh
vi /etc/hostname # 1. 호스트 이름 변경
vi /etc/hosts # 2. 호스트 이름 변경
```

3. Proxmox는 `/etc/pve/local/` 경로에서 현재 노드 이름을 사용하므로, `노드 이름을 변경`해야 합니다.

```sh
mv /etc/pve/local/pve-ssl.key /etc/pve/local/proxmox-server-ssl.key
mv /etc/pve/local/pve-ssl.pem /etc/pve/local/proxmox-server-ssl.pem
mv /etc/pve/local/pve /etc/pve/local/proxmox-server
```

## cluster 삭제

```bash
systemctl stop pve-cluster corosync
pmxcfs -l
rm -r /etc/pve/corosync.conf
rm -r /etc/corosync/*
killall -9 corosync
umount /etc/pve
systemctl restart pve-cluster
```


## vm의 이름 변경

```sh
qm set [VMID] --name [NAME]
#ex : qm set 9100 --name ubuntu2404-template
```