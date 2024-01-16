## 240113

### dotnet-script

https://github.com/dotnet-script/dotnet-script

```shell
dotnet tool install -g dotnet-script # 설치
dotnet tool list -g # 리스트 확인
dotnet tool uninstall -g dotnet-script # 삭제
```

실행할 스크립트를 `helloworld.csx` 에 저장
```cs
Console.WriteLine("Hello world!");
```

dotnet의 서브명령으로 실행하거나, 툴을 직접 실행
```shell
dotnet script helloworld.csx
```

note: 닷넷 툴 경로가 path에 잡혀있으면 `dotnet-script` 형식으로도 사용 가능. 경로 설정은 tool install 할 때 안내된다.

### tocmaker reference

tocmaker 실행으로 만들어질 output 포맷은 아래의 파일과 최대한 유사하게 맞춘다. 

https://github.com/jbranchaud/til/blob/master/README.md