`sshd_config` 파일 수정만으로는 안되는 듯. 

참고 : https://startdatastudy.tistory.com/51

## port 변경

`/etc/ssh/sshd_config` 파일을 수정합니다.

```bash
sudo vi /etc/ssh/sshd_config

#Port 22 <-- 이 줄을 찾아서 주석을 풀고 수정합니다.>
```

## services 파일 수정

`/etc/services` 파일도 수정해야 합니다.

```bash
sudo vi /etc/services

# ssh 22/tcp # SSH Remote Login Protocol <-- 이 줄을 찾아서 주석을 풀고 수정합니다.>
# ssh 22/udp # SSH Remote Login Protocol <-- 이 줄도 찾아서 주석을 풀고 수정합니다.>
```

## sshd 재시작

```bash
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
```