# nginx - 개발환경용 간단 실행

link : https://bakingdevlog.tistory.com/13

윈도우에서 서비스를 돌릴 생각은 없고, 개발 환경에서 CORS 오류 들을 우회하기 위해 간단히 실행하는 용도.

## 설치

1. https://nginx.org/en/download.html 에서 윈도우용 nginx 다운로드
2. 압축 해제
3. `nginx.exe` 실행
4. `http://localhost` 에서 접속 확인

## root 디렉토리 변경

`conf/nginx.conf` 파일에서 `location` 하위 `root` 디렉토리를 변경한다.
윈도우 경로 구분자를 그대로 쓰지 말고 슬래시(`/`)로 바꿔서 쓴다.

```nginx
        location / {
            root   "C:/path/to/your/project";  # 여기를 변경
            index  index.html index.htm;
        }
```

## nginx.exe 제어

계속 운영할 생각이 아니므로 서비스로 등록하지도 않는다. 실행파일 있는 폴더에서 명령 프롬프트를 열고 다음 명령어들을 사용한다.

- `.\nginx.exe` : 실행
- `.\nginx -s stop` : 즉시 종료
- `.\nginx -s reload` : 설정 파일 재적용 (재시작 아님)
- `.\nginx -t` : 설정 파일 문법 체크