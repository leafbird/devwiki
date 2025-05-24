# 1️⃣ Arch Linux: NetworkManager와 systemd-networkd 비교 설명

## 🚀 NetworkManager

✅ **장점**  
- 데스크탑 환경(GNOME, KDE 등)과의 통합이 우수  
- GUI 툴(`nm-connection-editor`)과 Applet을 통한 직관적 설정 가능  
- WiFi, VPN, 모바일 브로드밴드 등 다양한 네트워크를 한 번에 관리  
- 동적 IP나 무선 네트워크 연결을 자주 바꿀 때 편리  

❌ **단점**  
- 데스크탑 중심이라 서버 환경에서는 다소 오버헤드  
- GUI 없이 순수 파일 기반 설정은 다소 번거로움  

---

## ⚙️ systemd-networkd

✅ **장점**  
- **파일 기반 설정**으로 재현성 및 버전 관리 용이  
- 단순하고 가벼운 구조로 서버/가상화 환경에 적합  
- 부팅 시 빠르고 안정적으로 적용  
- 사용자와 무관하게 시스템 단위로 네트워크 관리  

❌ **단점**  
- GUI가 없고, CLI나 파일 편집으로만 관리  
- WiFi, VPN 등은 별도 툴(`iwd`, `systemd-resolved` 등) 설정 필요  
- 무선 네트워크를 자주 바꾸는 경우 불편할 수 있음  

---

## 🔎 기능 요약 비교

| 기능/특성         | **NetworkManager**               | **systemd-networkd**         |
|-------------------|---------------------------------|-----------------------------|
| 주 사용 환경       | 데스크탑, 모바일, 노트북             | 서버, 클라우드, 가상화 환경     |
| 무선 네트워크 관리   | 지원 (WiFi/VPN 등 GUI 포함)      | 직접 관리 불가 (`iwd` 등 필요) |
| VPN 관리          | 기본 지원                        | 외부 툴 필요                  |
| 설정 방식          | 명령어/GUI, DBus 기반 동적 관리  | 정적인 파일 설정               |
| 설정 파일 위치      | /etc/NetworkManager/ 등         | /etc/systemd/network/         |
| 부팅 속도/간결함    | 다소 무거움                      | 매우 빠르고 가벼움             |

---

## 💡 선택 가이드

- **데스크탑/노트북 (WiFi, VPN, 모바일 환경)** → **NetworkManager** 유지  
- **서버/고정 네트워크 (유선, 재현성 중요)** → **systemd-networkd** 추천  

---

## 🔄 변경 시 주의사항

- systemd-networkd로 전환 시:
  ```bash
  sudo systemctl disable --now NetworkManager
  sudo systemctl enable --now systemd-networkd
  ```
- WiFi나 DHCP 등 필요한 경우 추가로 `iwd`, `systemd-resolved` 설정 필요

---

# 2️⃣ Arch Linux: systemd-networkd에서 고정 IP 설정 방법

1️⃣ **systemd-networkd 활성화**
```bash
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
```

2️⃣ **인터페이스 이름 확인**
```bash
ip link
```

3️⃣ **설정 파일 생성**  
예시: `/etc/systemd/network/20-wired.network`
```ini
[Match]
Name=enp0s3   # 실제 인터페이스 이름으로 수정

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
```

4️⃣ **설정 적용**
```bash
sudo systemctl restart systemd-networkd
```

---

💡 **추가 팁**  
- DNS 설정이 더 필요하면 `/etc/systemd/resolved.conf` 설정 후:
  ```bash
  sudo systemctl enable --now systemd-resolved
  ```
- `resolvectl` 명령어로 현재 DNS 상태 확인 가능
