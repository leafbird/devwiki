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

## GitHub Packages의 Nuget 패키지 사용

`NuGet.Config` 파일은 여러 위치에서 설정될 수 있습니다.

`NuGet.Config`는 다음 순서로 탐색됩니다:

1. 프로젝트별 설정: 프로젝트 디렉터리나 하위 폴더에 위치한 `NuGet.Config`.
1. 사용자별 설정: 사용자의 홈 디렉터리에 위치한 `NuGet.Config`.
   * Windows: `C:\Users\<사용자 이름>\AppData\Roaming\NuGet\NuGet.Config`
   * macOS/Linux: `~/.config/NuGet/NuGet.Config`
1. 컴퓨터 전체 설정: 머신 전체를 대상으로 하는 구성 파일.
   * Windows: `C:\ProgramData\NuGet\NuGet.Config`

파일 내용 예시:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="github" value="https://nuget.pkg.github.com/<GitHub 계정명>/index.json" />
  </packageSources>
  <packageSourceCredentials>
    <github>
      <add key="Username" value="<GitHub 사용자명 또는 PAT>" />
      <add key="ClearTextPassword" value="<GitHub Personal Access Token>" />
    </github>
  </packageSourceCredentials>
</configuration>
```