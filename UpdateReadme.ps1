$targetFileName = "README.md"
$historyDataPath = "TIL"

# packages 폴더가 없다면 nuget에서 SitemapMaker 패키지를 다운로드 받는다.
if (!(Test-Path packages)) {
    Write-Output "packages 폴더가 없습니다. SitemapMaker 패키지를 다운로드 받습니다."
    nuget install SitemapMaker -OutputDirectory packages
}

# packages 폴더 하위에서 main.csx 파일을 찾아서 실행한다.
$main = Get-ChildItem -Path packages -Recurse -Filter main.csx | Select-Object -First 1
if ($main -eq $null) {
    Write-Output "main.csx 파일을 찾을 수 없습니다."
    exit 1
}
Write-Output "main.csx 파일을 찾았습니다. 실행합니다."
Write-Output "파일 경로: $($main.FullName)"

dotnet-script $main $targetFileName $historyDataPath