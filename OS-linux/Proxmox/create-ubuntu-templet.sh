#!/bin/bash
# Ubuntu 24.04 템플릿 자동 생성 스크립트
# 실행 위치: Proxmox host (root)

set -e

TEMPLATE_ID=9000
TEMPLATE_NAME="ubuntu-24.04-template"
ISO_PATH="local:iso/ubuntu-24.04.3-live-server-amd64.iso"
STORAGE="local-lvm"
BRIDGE="vmbr0"

echo "=== Ubuntu 24.04 템플릿 VM 생성 시작 ==="

# 1️⃣ 기존에 같은 ID의 VM이 있으면 삭제
if qm status $TEMPLATE_ID &>/dev/null; then
    echo "기존 VM($TEMPLATE_ID) 삭제 중..."
    qm stop $TEMPLATE_ID &>/dev/null || true
    qm destroy $TEMPLATE_ID --purge --destroy-unreferenced-disks 1
fi

# 2️⃣ VM 생성
echo "VM 생성 중..."
qm create $TEMPLATE_ID \
  --name $TEMPLATE_NAME \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=$BRIDGE \
  --scsihw virtio-scsi-pci \
  --scsi0 $STORAGE:32 \
  --bootdisk scsi0 \
  --boot c \
  --ostype l26 \
  --serial0 socket \
  --vga serial0

# 3️⃣ ISO 연결
qm set $TEMPLATE_ID --cdrom $ISO_PATH

# 4️⃣ QEMU Guest Agent 활성화
qm set $TEMPLATE_ID --agent enabled=1

# 5️⃣ 설치 안내
echo ""
echo "✅ 템플릿 생성 완료!"
echo "지금 Web UI에서 다음 VM으로 Ubuntu Server를 설치하세요:"
echo ""
echo "  VM ID: $TEMPLATE_ID"
echo "  Name:  $TEMPLATE_NAME"
echo "  ISO:   $ISO_PATH"
echo ""
echo "설치 시 유의사항:"
echo "  - 수동 네트워크 설정:"
echo "      IP: 192.168.50.91 (control), GW: 192.168.50.1"
echo "      DNS: 8.8.8.8"
echo "  - SSH 서버 설치 체크"
echo "  - 설치 후 아래 명령어로 QEMU Agent 활성화 확인:"
echo "      sudo apt update && sudo apt install -y qemu-guest-agent && sudo systemctl enable --now qemu-guest-agent"
echo ""
echo "설치 완료 후 템플릿으로 변환하세요:"
echo "  qm shutdown $TEMPLATE_ID"
echo "  qm template $TEMPLATE_ID"
echo ""
echo "=== 완료 ==="
