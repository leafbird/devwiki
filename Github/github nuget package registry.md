## 현재 설정을 확인하기

### 설정 파일 위치

Windows: `%appdata%\NuGet\NuGet.Config`
Mac/Linux: `~/.config/NuGet/NuGet.Config` or `~/.nuget/NuGet/NuGet.Config (varies by tooling)`

* Ubuntu 24.04.2 에서 위치는 `~/.nuget/Nuget/Nuget.Config`.
* iMac(2017) Ventura 13.7.3에서 위치도  `~/.nuget/Nuget/Nuget.Config`.

 
### 설정 파일 내용을 직접 확인하고 싶은 경우

Windows:

```powershell
Get-Content (Join-Path $env:appdata "Nuget\Nuget.Config")
```

Linux / MacOS:

```sh
cat ~/.nuget/NuGet/NuGet.Config
```

### dotnet 명령으로 현재 구성된 소스 리스트 확인

```sh
dotnet nuget list source
```
 

## 설정 추가

### github 개인 키 설정

Windows:

```powershell
dotnet nuget add source "https://nuget.pkg.github.com/StudioBside/index.json" `
  --name github `
  --username YOUR_GITHUB_USERNAME `
  --password YOUR_GITHUB_TOKEN `
  --store-password-in-clear-text
```

Linux / MacOS: (줄바꿈 표기만 다름)

```sh
dotnet nuget add source "https://nuget.pkg.github.com/StudioBside/index.json" \
  --name github \
  --username YOUR_GITHUB_USERNAME \
  --password YOUR_GITHUB_TOKEN \
  --store-password-in-clear-text
```

### gitlab

project id 확인 : project settings > general > project ID

deploy tokens 발급 : project settings > repository > deploy tokens
 - read_repository, read_package_registry, write_package_registry 권한 다 넣고 Username devman 넣어줌.

사내 gitlab이 https를 사용하지 않으므로 insecure 옵션을 추가해야 함.

Windows:

```powershell 
dotnet nuget add source "http://gitlab.bside.com/api/v4/projects/94/packages/nuget/index.json" `
 --name gitlab `
 --username buildman `
 --password <YOUR_GITLAB_TOKEN> `
 --store-password-in-clear-text `
 --allow-insecure-connections
```

Linux / MacOS: (줄바꿈 표기만 다름)
 
```sh
dotnet nuget add source "http://gitlab.bside.com/api/v4/projects/94/packages/nuget/index.json" \
 --name gitlab \
 --username buildman \
 --password <YOUR_GITLAB_TOKEN> \
 --store-password-in-clear-text \
 --allow-insecure-connections
```

## 레지스트리에 배포된 tool 사용

### 윈도우 아닌 경우 초기설정

linux인 경우 최초 한 번 `$PATH`에 경로 등록 필요. macOs와 호환위해 $HOME 변수 사용

```sh
cat << \EOF >> ~/.zshrc
# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"
EOF
source .zshrc
```
 
### 설치

버전을 생략하면 어째서인지 예외만 던지고 실행되지 않는다. (401 Unauthorized 발생)

```sh
# windows
dotnet tool install -g TOOL_NAME `
  --version TOOL_VERSION `
  --add-source "https://nuget.pkg.github.com/StudioBside/index.json"

# linux
dotnet tool install -g TOOL_NAME \
  --version TOOL_VERSION \
  --add-source "https://nuget.pkg.github.com/StudioBside/index.json"
```
 
### 기타 관리 명령

```sh
# 목록 확인
dotnet tool list -g

# 삭제
dotnet tool uninstall -g TOOL_NAME

# 버전 업데이트
dotnet tool update -g TOOL_NAME
```

## 레지스트리에 배포

```sh 
# Not required, but needed to prevent warnings
nuget setApiKey YOUR_GITHUB_TOKEN -Source "github"

dotnet pack -c Release --version-suffix 0.0.2
nuget push ./nupkg/star.0.0.2.nupkg -Source "github"
```

설정에 apiKey가 지정 안된 경우 경고 예시:

```text
패키지 파일 생성 완료. 경로: .\nupkg\star.0.0.7.nupkg
경고: No API Key was provided and no API Key could be found for 'https://nuget.pkg.github.com/StudioBside'.  To save an API Key for a source use the 'setApiKey' command.
Pushing Star.0.0.7.nupkg to 'https://nuget.pkg.github.com/StudioBside'... 
  PUT https://nuget.pkg.github.com/StudioBside/ 
경고: Please use the --api-key option when publishing to GitHub Packages
  OK https://nuget.pkg.github.com/StudioBside/  4705ms
Your package was pushed.
```

## See Also

https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior