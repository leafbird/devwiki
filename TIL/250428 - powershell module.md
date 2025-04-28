# powershell module

## 모듈을 빌드하고 repo에 올리기

매니페스트 파일 생성

```powershell
New-ModuleManifest -Path 'C:\MyModules\PsBside\PsBside.psd1' `
    -RootModule 'PsBside.psm1' `
    -ModuleVersion '1.0.0' `
    -Author 'YourName' `
    -Description 'Common PowerShell utilities for internal use'
```

공유폴더를 PSRepository로 등록

```powershell
# 처음 한 번만 실행
Register-PSRepository -Name 'MyCompanyRepo' `
    -SourceLocation '\\MyCompanyServer\PsRepo' `
    -PublishLocation '\\MyCompanyServer\PsRepo' `
    -InstallationPolicy Trusted
```

Publish-Module을 사용하여 모듈을 배포

```powershell
Publish-Module -Path 'C:\MyModules\PsBside' -Repository 'MyCompanyRepo'
```

## 내부 저장소(공유폴더)에서 모듈 설치

```powershell
# 처음 한 번만 실행
Register-PSRepository -Name 'MyCompanyRepo' `
    -SourceLocation '\\MyCompanyServer\PsRepo' `
    -InstallationPolicy Trusted

Install-Module -Name 'PsBside' -Repository 'MyCompanyRepo'
```

## 모듈 관련 추가 명령들

```powershell

Get-Module -ListAvailable   # 모듈 목록 보기 : 사용 가능한 모든 모듈
Get-Module                  # 모듈 목록 보기 : 현재 세션에서 사용 중인 모듈
Remove-Module -Name 'ModuleName' -Force # 모듈 강제 삭제

Get-PSRepository                         # 등록된 PSRepository 목록 보기
Unregister-PSRepository -Name 'RepoName' # PSRepository 등록 해제
```