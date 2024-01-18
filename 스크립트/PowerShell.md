## 버전 확인하기

출처 : https://stackoverflow.com/questions/1825585/determine-installed-powershell-version

```
PS C:\> $PSVersionTable.PSVersion

Major  Minor  Build  Revision
-----  -----  -----  --------
4      0      -1     -1
```

### make symbolic link

출처 : https://superuser.com/questions/1307360/how-do-you-create-a-new-symlink-in-windows-10-using-powershell-not-mklink-exe

+-----------------------+-----------------------------------------------------------+
| mklink syntax         | Powershell equivalent                                     |
+-----------------------+-----------------------------------------------------------+
| mklink Link Target    | New-Item -ItemType SymbolicLink -Name Link -Target Target |
| mklink /D Link Target | New-Item -ItemType SymbolicLink -Name Link -Target Target |
| mklink /H Link Target | New-Item -ItemType HardLink -Name Link -Target Target     |
| mklink /J Link Target | New-Item -ItemType Junction -Name Link -Target Target     |
+-----------------------+-----------------------------------------------------------+

### How to Execute a .bat File within a PowerShell Job

출처 : http://insight.mvpsi.com/tag/start-process/

You can start a command procedure from PowerShell with the following code. Replace the path and file with your own information.
    C:\Path\file.bat
Once you’ve called your batch file, you can customize it to the task at hand. For example…
If you want to capture the output of the .bat file, you can use:
    $out = C:\Path\file.bat
If you want to start a process with your .bat file, you can use the PowerShell start-process cmdlet:
    start-process C:\Path\file.bat
And, if you if you want to control cmd.exe, you can use this:
    start-process "cmd.exe" "/c C:\Path\file.bat"
    
    
### Manipulate String 

출처 : http://technet.microsoft.com/en-us/library/ee692804.aspx

### powershell에서 환경설정을 확장하는 (path에 값추가) batch파일 실행

* pscx를 설치 https://www.powershellgallery.com/packages/Pscx/3.2.2
* invoke-batchfile "xx.bat" 실행.
```
   PS C:\Users\Administrator> Install-Module -Name Pscx -RequiredVersion 3.2.2 -AllowClobber 
```
설치하면 압축파일 해제하는 Expand-Archive의 인자이름이 바뀌므로 주의해야 한다.
* Expand-Archive 기본형은 압축 해제 경로를 '-DestinationPath'로 지정
* Pscx에 설치되는 명령은 '-OutputPath'로 지정.

### 파일 압축하는 세 가지 방법
출처 : https://ridicurious.com/2019/07/29/3-ways-to-unzip-compressed-files-using-powershell/

1번에 비해 2번이 상당히 빠른 것 같다. 제대로 비교 테스트 해보진 않았음. 확인 필요. 

```
# Method 1 - Using Expand-Archive cmdlet
Expand-Archive -Path C:\Data\Compressed.zip -DestinationPath C:\Data\one -Verbose

# Method 2 - Using .Net ZipFile Class
Add-Type -Assembly "System.IO.Compression.Filesystem"
[System.IO.Compression.ZipFile]::ExtractToDirectory('C:\Data\Compressed.zip','C:\Data\two')

# Method 3 - Using Shell.Application COM object
$ZippedFilePath = "C:\Data\Compressed.zip"
$DestinationFolder = "C:\Data\three\"
[void] (New-Item -Path $DestinationFolder -ItemType Directory -Force)
$Shell = new-object -com Shell.Application
$Shell.Namespace($DestinationFolder).copyhere($Shell.NameSpace($ZippedFilePath).Items(),4) 
```


### 명령행 인자 받는 방법

param(
    [string] $sourceName = 'defaultSourceName',
    [Parameter(Mandatory=$true)][string] $targetPath = '.\defaultPath',
    [string] $executableFileName = 'default.exe'
)

### asp.net 에서 파워쉘 실행하는 법

powershell 객체를 사용하는 예제 : http://jeffmurr.com/blog/?p=142
pipeline 객체를 사용하는 예제 : https://forums.asp.net/t/2011253.aspx?Run+powershell+script+in+asp+net+webpage+

```
using System.Management.Automation;

   public string Get(string value)
        {
            var shell = PowerShell.Create();
            shell.Commands.AddScript(value);
            var results = shell.Invoke();

            if (results.Count == 0)
            {
                return "Done";
            }

            var builder = new StringBuilder();
            foreach (var data in results)
            {
                builder.Append(data.BaseObject.ToString() + Environment.NewLine);
            }

            return builder.ToString();
        }
```

### http request 날리기

```
$result = Invoke-WebRequest http://localhost:9125/api/Process?value=C:\Temp\temp.ps1 -Method Get
$result | convertto-json -depth 10
```

### 이메일 전송

참고 : 
- https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/send-mailmessage?view=powershell-7
- https://blog.mailtrap.io/powershell-send-email/
- https://blogs.msdn.microsoft.com/koteshb/2010/02/12/powershell-how-to-create-a-pscredential-object/

```
$subject = "pvs studio analysis 2"
$body = "hello world"

$secpasswd = ConvertTo-SecureString "<계정비번>" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("reporter@zzz.com", $secpasswd)

Send-MailMessage `
    -To "xxx@yyy.com" `
    -From "reporter@zzz.com" `
    -Subject $subject `
    -Body $body `
    -Credential $mycreds `
    -SmtpServer <서버주소> `
    -Port <포트번호> `
    -UseSsl
```
