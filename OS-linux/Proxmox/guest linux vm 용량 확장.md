# Proxmox : guest linux vm 용량 확장

참고 : https://svrforum.com/svr/1029266

## 대시보드에서 사이즈 변경

해당vm의 하드웨어 -> 하드디스크 -> 디스크 Action -> 크기 조정

delta값만 입력한다. 최종값은 자동으로 계산된다.


## 파티션 확장

모든 명령에 admin 권한 필요. 

```bash
sudo -su

fdisk -l # 현재 파티션 확인. 사이즈가 안 맞다는 오류 메시지가 뜬다. (GPT PMBR size mismatch...)
parted -l # 입력 후 F 입력해서 fix
fdisk -l # 다시 확인. 사이즈가 맞아진다.

growpart /dev/sda 3 # 파티션 확장
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv # 논리 볼륨 확장
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv # 파일 시스템 확장

fdisk -l # 확인
df -h # 확인
```