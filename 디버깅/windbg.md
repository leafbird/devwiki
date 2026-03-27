## WinDbg 가이드

syntax highlighting : http://dbgext.biglasagne.com/extensions/uienh_asmhl.html

## 1. 초기 설정 (덤프 로드 후 필수)
덤프 파일을 드래그하여 연 후, .NET 환경 및 심볼을 설정하기 위해 다음 순서대로 입력합니다.

### 심볼 경로 설정
기존 Microsoft 서버에 자체 심볼 서버(Backup 포함)를 추가하는 명령입니다.
```dbg
# Microsoft 심볼 서버 + 자체 심볼 서버 2곳 설정
.sympath srv*c:\symbols*https://msdl.microsoft.com/download/symbols;Q:\Published\Symbols.linux-x64;Q:\Published\Symbols.linux-x64.Backup

# 심볼 강제 다시 로드
.reload /f
```

### SOS 확장 로드
.NET Core / 5+ 환경 분석을 위한 SOS 디버거 확장을 로드합니다.
```dbg
# SOS 로드 (설치 경로 확인 필요)
.load C:\Users\choisungki\.dotnet\sos\sos.dll

# 로드 확인 (버전 정보 출력 시 성공)
!eeversion
```
> **참고 (Linux 덤프):** Alpine Linux 기반 덤프 로드 시 `ld-musl` 관련 경고가 뜰 수 있으나, 매니지드 코드 분석에는 무시해도 무방합니다.

---

## 2. 주요 분석 명령어

### 예외 및 콜스택
| 명령 | 내용 |
| - | - |
| **!analyze -v** | 덤프파일 자동 분석 및 요약 |
| **.ecxr** | 예외가 발생한 컨텍스트로 이동 |
| **k** | 네이티브 콜스택 출력 |
| **!clrstack** | 매니지드(.NET) 콜스택 출력 |
| **~*e !clrstack** | 모든 스레드의 매니지드 콜스택 일괄 출력 |
| **.frame <번호>** | 지정한 스택 프레임으로 이동 |
| **dt <변수명>** | 로컬/멤버 변상 상세 내용 확인 |
| **!pe** | 현재 스레드의 예외 객체 상세 정보 출력 (Print Exception) |

### 힙(Heap) 및 객체 분석
특정 타입의 객체가 메모리를 많이 점유할 때 사용합니다.

```dbg
# 85KB 미만(SOH)의 System.Byte[] 통계 요약
!dumpheap -type System.Byte[] -min 0 -max 85000 -stat

# 특정 MT(MethodTable) 주소를 가진 객체들 중 특정 크기 범위 리스팅
!dumpheap -mt <MT주소> -min 7000 -max 8000

# 특정 클래스 타입의 모든 객체 통계
!dumpheap -type <클래스명> -stat
```

### 참조 추적 (GC Root)
객체가 해제되지 않고 왜 살아있는지(누수 원인) 확인하는 핵심 명령입니다.
```dbg
# 특정 주소의 객체를 붙잡고 있는 루트 경로 추적
!gcroot <객체주소>
```
> **분석 포인트:** 스택에 `Task.Wait()`, `.Result`, `SpinThenBlockingWait` 등이 보인다면 **Sync-over-Async**에 의한 병목 및 버퍼 누적을 의심하십시오.

---

## 3. 데이터 확인 (Memory Dump)
객체 내부의 실제 데이터를 읽을 때 사용합니다.

```dbg
# 데이터 시작 지점(보통 헤더 제외 +0x18)부터 16진수 및 ASCII로 확인
dc <객체주소>+0x18 L20

# 16진수 바이트만 가볍게 확인
db <객체주소>+0x18
```

---

## 4. 기타 팁
- **명령 중단:** `Ctrl + Break`
- **심볼 로드 상세 로그:** `!sym noisy` (문제가 생길 때만 켤 것)
- **심볼 로그 끄기:** `!sym quiet`
