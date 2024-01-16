## windbg

syntax highlighting : http://dbgext.biglasagne.com/extensions/uienh_asmhl.html

## 심볼파일 설정
.sympath \\xxx\xxx
.reload

## 소스경로 설정
.srcpath SRV*

## 주요 명령어
| 명령 | 내용 |
| - | - |
| !analyze -v | 덤프파일 분석 |
| .ecxr | 예외가 발생한 컨택스트로 변경 |
|k | 콜스택 출력|
|.frame | 지정한 스택 프레임으로 이동 (ex: .frame 1) 스택 프레임 번호는 kn으로 확인.|
|dt | 변수 내용 보기 (ex: dt this)|
|dv | 지역변수 보기|



## sos.dll

참고 :
- https://docs.microsoft.com/ko-kr/windows-hardware/drivers/debugger/debugging-managed-code#getting-the-sos-debugging-extension

### quick start

load sos
    .coredll -ve -u -l

​    
