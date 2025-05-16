# Gmail SMTP를 libsasl2-modules에 설정하는 방법

이 문서는 2025년 5월 기준 Gmail SMTP를 `libsasl2-modules`에 설정하는 최신 방법을 설명합니다. Google의 보안 정책(2단계 인증 및 앱 비밀번호 필수)을 반영하며, Postfix를 예로 들어 설정 과정을 안내합니다.

## 1. Gmail 계정에서 2단계 인증 활성화

앱 비밀번호는 2단계 인증(2FA)이 활성화된 계정에서만 생성 가능합니다.

1. **Google 계정 로그인**:
   - 브라우저에서 [myaccount.google.com](https://myaccount.google.com)에 접속.

2. **보안 설정 이동**:
   - 왼쪽 메뉴에서 **보안** 탭 선택.
   - **Google에 로그인** 섹션에서 **2단계 인증** 찾기.

3. **2단계 인증 설정**:
   - **시작하기** 클릭 후 안내 따르기.
   - 휴대폰 번호 또는 Google Authenticator 앱으로 인증 코드 설정.
   - 설정 완료 후 **사용** 상태 확인.

## 2. 앱 비밀번호 생성

Gmail SMTP에 사용할 16자리 앱 비밀번호를 생성합니다.

1. **앱 비밀번호 페이지 이동**:
   - **보안** 탭에서 **2단계 인증** 하단의 **앱 비밀번호** 클릭.
   - 표시되지 않을 경우, Google 계정 검색창에 **앱 비밀번호** 또는 **App passwords** 입력.
   - **참고**: 직장/학교 계정 또는 고급 보호 활성화 시 앱 비밀번호 옵션이 제한될 수 있음. 개인 Gmail 계정 사용 권장.

2. **앱 비밀번호 생성**:
   - **앱 선택** 드롭다운에서 **기타 (맞춤 이름)** 선택.
   - 앱 이름 입력 (예: `SMTP for libsasl2`) 후 **생성** 클릭.
   - 16자리 앱 비밀번호 복사 및 안전한 곳에 저장. 화면 닫으면 재확인 불가.

## 3. Gmail SMTP 설정 정보

`libsasl2-modules`에서 사용할 Gmail SMTP 서버 정보:

- **SMTP 서버**: `smtp.gmail.com`
- **포트**: `587` (STARTTLS) 또는 `465` (SSL/TLS)
- **사용자 이름**: Gmail 주소 (예: `your.email@gmail.com`)
- **비밀번호**: 생성한 16자리 앱 비밀번호
- **인증 방식**: SASL PLAIN (libsasl2 기본)

## 4. libsasl2-modules에서 SMTP 설정

Postfix를 예로 들어 `libsasl2-modules` 설정 방법을 설명합니다.

### 4.1. SASL 비밀번호 파일 생성

1. `/etc/postfix/sasl_passwd` 파일 편집:

   ```plaintext
   [smtp.gmail.com]:587 your.email@gmail.com:your-app-password
   ```

   - `your-app-password`는 생성한 앱 비밀번호.

2. 파일 권한 설정 및 Postfix 맵 생성:

   ```bash
   sudo chmod 600 /etc/postfix/sasl_passwd
   sudo postmap /etc/postfix/sasl_passwd
   ```

### 4.2. Postfix 설정

`/etc/postfix/main.cf` 파일에 다음 추가/수정:

```plaintext
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = may
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```

### 4.3. Postfix 재시작

```bash
sudo systemctl restart postfix
```

### 4.4. SASL 모듈 확인

- 설치 확인:

  ```bash
  dpkg -l | grep libsasl2-modules
  ```

- 필요 시 설치:

  ```bash
  sudo apt-get install libsasl2-modules
  ```

## 5. IMAP/POP 설정 (선택 사항)

IMAP/POP 사용 시 Gmail에서 활성화:

1. Gmail 웹 인터페이스: **설정 > 모든 설정 보기 > 전달 및 POP/IMAP** 탭.
2. **IMAP 사용** 또는 **POP 사용** 체크 후 저장.

## 6. 테스트 및 문제 해결

### 6.1. 테스트

- 메일 전송 테스트:

  ```bash
  echo "Test email" | mail -s "Test" recipient@example.com
  ```

- 로그 확인:

  ```bash
  sudo tail -f /var/log/mail.log
  ```

### 6.2. 문제 해결

- **SMTPAuthenticationError**: 앱 비밀번호 오류 또는 2단계 인증 비활성화. 비밀번호 재확인.
- **앱 비밀번호 옵션 안 보임**: Google 계정 검색 또는 개인 계정 사용.
- **TLS 오류**: 포트 `587`에 STARTTLS 활성화 확인.
- **계정 차단**: Gmail 보안 알림 확인 및 **활동 승인**.

## 참고사항

- Google은 OAuth 2.0 인증 권장. 하지만 `libsasl2-modules`는 SASL PLAIN 사용이 간단.
- OAuth 2.0 필요 시 `sasl-xoauth2` 플러그인 설치.
- 앱 비밀번호 분실 시 새로 생성.
- Google Workspace 계정은 관리자 설정에 따라 제한 가능.

---

**작성일**: 2025년 5월 16일
