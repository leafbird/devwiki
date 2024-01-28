## migration core3.1 -> 5.0

https://docs.microsoft.com/ko-kr/aspnet/core/migration/31-to-50?view=aspnetcore-5.0&tabs=visual-studio


```
Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse } # obj, bin 폴더 삭제
dotnet nuget locals --clear all # nuget의 캐시 삭제

```

### 윈도우만 타겟으로 지정하기

https://stackoverflow.com/questions/67117053/ca1416-how-to-tell-builder-that-only-platform-is-windows

```
You can mark each windows-specific method with System.Runtime.Versioning.SupportedOSPlatformAttribute e.g.

[SupportedOSPlatform("windows")]
public static void Foo()
    => Thread.CurrentThread.SetApartmentState(ApartmentState.STA);

Mark entire assembly with in AssemblyInfo (if you have one)
[assembly: System.Runtime.Versioning.SupportedOSPlatformAttribute("windows")]

Or edit .csproj file to target windows-specific version of dotnet to make these changes automatic
<TargetFramework>net5.0-windows</TargetFramework>
```

### CA1060 P/Invoke 메소드 위치 이슈

https://docs.microsoft.com/ko-kr/dotnet/fundamentals/code-analysis/quality-rules/ca1060