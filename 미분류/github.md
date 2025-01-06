# github

## workflow

### 특정 job을 비활성화 하고 싶을 때

```yaml
    push-to-nuget:
    needs: build
    runs-on: ubuntu-latest
    
    if: false # github package 테스트를 위해 잠시 비활성화
      
    steps:
```

### github 패키지 레지스트리에서 패키지 읽어오기

credential을 nuget.config에 저장하고 사용한다.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="github" value="https://nuget.pkg.github.com/OWNER/index.json" />
  </packageSources>
  <packageSourceCredentials>
    <github>
      <add key="Username" value="OWNER" />
      <add key="ClearTextPassword" value="PERSONAL_ACCESS_TOKEN" />
    </github>
  </packageSourceCredentials>
</configuration>
```

nuget.config 위치는 

* 윈도우 기준 `%APPDATA%\NuGet\nuget.config`
* 리눅스 기준 `~/.nuget/NuGet/NuGet.Config`
