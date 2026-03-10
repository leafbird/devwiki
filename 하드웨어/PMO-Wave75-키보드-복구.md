# PMO Wave75 RGB 키보드 복구 가이드

키보드: PMO Wave75 RGB (웨이브75)
제조사: PMO (pmolab.cn)
VID/PID: `0x36B0` / `0x3009`
펌웨어: QMK 기반, VIA 지원

## 증상

케이블 분리 후 재연결 시 다음 문제가 발생할 수 있다:

- VIA에서 키보드가 인식되지 않음
- 커스텀 키 바인딩이 초기화됨 (EEPROM 리셋)
- RGB 설정이 기본값으로 돌아감

주요 원인: 청소 등의 이유로 케이블을 뺐다 꽂는 과정에서 `Fn + Backspace` (QK_CLEAR_EEPROM) 조합이 눌리거나, 전원 불안정으로 EEPROM이 초기화될 수 있다.

## VIA에서 키보드 인식시키기

PMO Wave75는 VIA 기본 키보드 목록에 포함되어 있지 않다. 매번 수동으로 키보드 정의 파일을 로드해야 한다.

1. VIA 실행 (웹: [usevia.app](https://usevia.app) 또는 데스크톱 앱)
2. **Settings** 탭 → **Show Design Tab** 활성화
3. **Design** 탭 → **Load Draft Definition** → 아래 정의 파일 로드:
   - [`wave75-rgb-via-definition.json`](wave75-config/wave75-rgb-via-definition.json)
4. **Configure** 탭으로 돌아가면 키보드가 인식됨

## 레이아웃(키맵) 복원

VIA에서 키보드 인식 후:

1. **Configure** 탭 → 좌측 하단 **Save + Load**
2. **Load Saved Layout** → 백업 파일 선택:
   - [`wave75-layout-backup-20250822.json`](wave75-config/wave75-layout-backup-20250822.json) — 가장 최근 백업 (4레이어, CUSTOM 키코드 포함)
   - [`wave75-layout-backup-20250321.json`](wave75-config/wave75-layout-backup-20250321.json) — 이전 백업

### 레이어 구성 (20250822 백업 기준)

| 레이어 | 용도 |
|--------|------|
| Layer 0 | 기본 (Win) — 표준 QWERTY |
| Layer 1 | 기본 (Mac) — Ctrl/Alt/GUI 위치 변경 |
| Layer 2 | Fn (Win) — RGB 제어, CUSTOM 키코드, EEPROM 리셋 |
| Layer 3 | Fn (Mac) — Layer 2와 동일 구조, GUI 위치 상이 |

## 펌웨어 플래싱 (심각한 문제 시)

키보드가 아예 인식되지 않거나 부팅이 안 되는 경우에만 수행한다.

1. PMO 공식 다운로드 페이지: [pmolab.cn/col.jsp?id=113](https://pmolab.cn/col.jsp?id=113)
2. 필요한 파일:
   - `WAVE75三模RGB（QMK代码）.bin` — 3모드 RGB QMK 펌웨어
   - `WAVE75键盘升级包.exe` — 키보드 업그레이드 도구
   - `WAVE75升级流程.doc` — 업그레이드 절차 문서
3. QMK Toolbox 또는 제조사 업그레이드 도구로 `.bin` 파일 플래싱

## 설정 파일 목록

```
하드웨어/wave75-config/
├── wave75-rgb-via-definition.json    # VIA 키보드 정의 (필수)
├── wave75-layout-backup-20250822.json # 레이아웃 백업 (최신)
└── wave75-layout-backup-20250321.json # 레이아웃 백업 (이전)
```

## USB 장치 확인 (Windows)

키보드 연결 상태를 확인하려면 PowerShell에서:

```powershell
Get-PnpDevice | Where-Object { $_.InstanceId -match '36B0' } | Select-Object Status, Class, InstanceId | Format-Table -AutoSize
```

`Status`가 `OK`이면 정상 연결 상태.
