## 유니코드 관련된 에러 발생할 때

오류 내용 : 
```
C:\Program Files\Amazon\AWSCLI\.\dateutil\parser.py:336: UnicodeWarning: Unicode  equal comparison failed to convert both arguments to Unicode - interpreting them as being unequal
```
출처 : https://github.com/aws/aws-cli/issues/424
python 3.X 버전을 사용하는 배포를 설치하여 해결.

```
Here is my work around on Windows

Uninstall https://s3.amazonaws.com/aws-cli/AWSCLI64.msi
Install Python 3.6.1
Run pip install awscli
Run aws --version ,and you will get aws-cli/1.11.102 Python/3.6.1 Windows/10 botocore/1.5.65
```


## File association not found for extension .py 에러 발생시
확장명 .py에 대한 파일 연결이 없습니다.

https://github.com/aws/aws-cli/issues/3548

aws cli

pip install awscli

```
C:\Users\...>aws --version
File association not found for extension .py
aws-cli/1.16.9 Python/3.6.6 Windows/7 botocore/1.11.9
```

```
assoc .py=py_auto_file
ftype py_auto_file="%USERPROFILE%\AppData\Local\Programs\Python\Python36\python.exe" "%1" %*
```

## aws 경로 찾을 수 없을 때

https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html

where /R c:\ aws 명령으로 위치를 직접 찾는다. 여러개 나오면 aws.cmd 로 골라서 path에 넣어준다.