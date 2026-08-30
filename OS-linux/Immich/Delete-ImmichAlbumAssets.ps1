# ==== 환경 변수 설정 ====
# 환경 변수에서 값을 가져오거나 기본값 사용
# 환경 변수 설정 방법:
# $env:IMMICH_URL = "https://your-immich-server.com"
# $env:IMMICH_EMAIL = "your@email.com"
# $env:IMMICH_PASSWORD = "yourpassword"

# 환경 변수에서 값을 가져옴
$ImmichUrl = $env:IMMICH_URL
$email = $env:IMMICH_EMAIL
$password = $env:IMMICH_PASSWORD

# 환경 변수 검증
if (-not $ImmichUrl) {
    Write-Host "❌ 환경변수 IMMICH_URL이 설정되지 않았습니다." -ForegroundColor Red
    Write-Host "PowerShell에서 다음과 같이 설정하세요: `$env:IMMICH_URL = 'https://your-immich-server.com'" -ForegroundColor Yellow
    exit 1
}

if (-not $email) {
    Write-Host "❌ 환경변수 IMMICH_EMAIL이 설정되지 않았습니다." -ForegroundColor Red
    Write-Host "PowerShell에서 다음과 같이 설정하세요: `$env:IMMICH_EMAIL = 'your@email.com'" -ForegroundColor Yellow
    exit 1
}

if (-not $password) {
    Write-Host "❌ 환경변수 IMMICH_PASSWORD가 설정되지 않았습니다." -ForegroundColor Red
    Write-Host "PowerShell에서 다음과 같이 설정하세요: `$env:IMMICH_PASSWORD = 'yourpassword'" -ForegroundColor Yellow
    exit 1
}

# 스크립트 버전 정보
$scriptVersion = "1.2.0"
Write-Host "Immich 앨범 자산 삭제 스크립트 v$scriptVersion"
Write-Host "--------------------------------------------"
Write-Host "서버 URL: $ImmichUrl"
Write-Host "이메일: $email"
Write-Host "비밀번호: 설정됨" -ForegroundColor Yellow

# TLS 1.2 사용 설정
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# SSL 인증서 검증 무시 설정
$script:skipCertParams = @{SkipCertificateCheck = $true}
Write-Host "SSL 인증서 검증을 무시합니다." -ForegroundColor Yellow

# =====================

function Get-AccessToken {
    Write-Host "🔐 Immich 로그인 중..."
    $body = @{
        email = $email
        password = $password
    } | ConvertTo-Json

    try {
        $params = @{
            Uri = "$ImmichUrl/api/auth/login"
            Method = "POST"
            Body = $body
            ContentType = "application/json"
        }
        
        # PowerShell 버전에 따라 매개변수 추가
        $invokeParams = $params + $script:skipCertParams
        
        $response = Invoke-RestMethod @invokeParams
        return $response.accessToken
    }
    catch {
        Write-Host "❌ 로그인 실패." -ForegroundColor Red
        Write-Host "오류 메시지: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.InnerException) {
            Write-Host "내부 오류 메시지: $($_.Exception.InnerException.Message)" -ForegroundColor Red
        }
        
        # 응답 상태 코드 정보 (있는 경우)
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Host "상태 코드: $($statusCode) - $($statusDescription)" -ForegroundColor Yellow
            
            # 응답 본문 내용 확인 (있는 경우)
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                $reader.Close()
                if ($responseBody) {
                    Write-Host "응답 내용:" -ForegroundColor Yellow
                    Write-Host $responseBody -ForegroundColor Yellow
                }
            }
            catch {
                # 응답 본문을 읽지 못하는 경우 무시
            }
        }
        
        Write-Host "로그인 정보와 서버 URL을 확인하세요." -ForegroundColor Yellow
        exit 1
    }
}

function Get-Albums {
    param ($token)
    
    $params = @{
        Uri = "$ImmichUrl/api/albums"
        Method = "GET"
        Headers = @{ Authorization = "Bearer $token" }
    }
    
    # PowerShell 버전에 따라 매개변수 추가
    $invokeParams = $params + $script:skipCertParams
    
    try {
        $albums = Invoke-RestMethod @invokeParams

        if (-not $albums) {
            Write-Log "📂 앨범이 없습니다." -ForegroundColor Yellow -LogToFile
            exit
        }

        Write-Host "`n📋 앨범 목록:"
        $albums | Sort-Object -Property albumName | ForEach-Object {
            $assetCount = if ($_.assetCount) { "$($_.assetCount)개 자산" } else { "자산 수 정보 없음" }
            Write-Host ("- " + $_.albumName + " (ID: '" + $_.id + "', $assetCount)")
        }

        return $albums
    }
    catch {
        Write-Host "❌ 앨범 목록을 가져오는데 실패했습니다." -ForegroundColor Red
        Write-Host "오류 메시지: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Remove-AlbumItself {
    param (
        $token,
        $albumId
    )
    $headers = @{ Authorization = "Bearer $token" }
    $maxRetries = 3  # 최대 재시도 횟수
    
    # 앨범 자체도 삭제할지 물어보기
    $deleteAlbum = Read-Host "앨범 자체도 삭제하시겠습니까? (yes 입력 시 진행)"
    
    if ($deleteAlbum -eq "yes") {
        Write-Log -Message "`n🗑️ 앨범 삭제 진행 중..." -ForegroundColor Yellow -LogToFile
        
        $deleteAlbumParams = @{
            Uri = "$ImmichUrl/api/albums/$albumId"
            Method = "DELETE"
            Headers = $headers
        }
        
        $deleteAlbumInvokeParams = $deleteAlbumParams + $script:skipCertParams
        
        $retryCount = 0
        $success = $false
        
        # 재시도 로직
        while (-not $success -and $retryCount -lt $maxRetries) {
            try {
                Invoke-RestMethod @deleteAlbumInvokeParams | Out-Null
                Write-Log -Message "✅ 앨범 삭제 완료." -ForegroundColor Green -LogToFile
                $success = $true
            }
            catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Log -Message "⚠️ 앨범 삭제 중 오류 발생: $($_.Exception.Message) - 재시도 중 ($retryCount/$maxRetries)..." -ForegroundColor Yellow -LogToFile
                    Start-Sleep -Seconds (2 * $retryCount)  # 지수적 백오프
                }
                else {
                    Write-Log -Message "❌ 앨범 삭제 실패 (최대 재시도 횟수 초과): $($_.Exception.Message)" -ForegroundColor Red -LogToFile
                }
            }
        }
    }
    else {
        Write-Log -Message "앨범은 유지되었습니다." -ForegroundColor Yellow -LogToFile
        
        # 로그 요약 표시
        if ($script:LogFile) {
            Write-Log -Message "`n📝 로그 파일이 저장되었습니다: $($script:LogFile)" -ForegroundColor Cyan -LogToFile
            Write-Log -Message "자세한 작업 내역은 로그 파일을 확인하세요." -LogToFile
        }
    }
}

function Write-Log {
    param (
        [string]$Message,
        [string]$ForegroundColor = "White",
        [switch]$LogToFile
    )
    
    # 콘솔에 메시지 출력
    Write-Host $Message -ForegroundColor $ForegroundColor
    
    # 로그 파일에 기록
    if ($LogToFile -and $script:LogFile) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $Message" | Out-File -Append -FilePath $script:LogFile
    }
}

function Remove-AlbumAssets {
    param (
        $token,
        $albumId
    )
    $headers = @{ Authorization = "Bearer $token" }
    $maxRetries = 3  # 최대 재시도 횟수
    
    # 로그 파일 생성 (선택 사항)
    $script:LogFile = "Immich-AlbumDelete-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    Write-Log -Message "로그 파일 생성됨: $($script:LogFile)" -ForegroundColor Cyan -LogToFile

    Write-Log -Message "`n📥 자산 목록 불러오는 중..." -LogToFile
    $albumParams = @{
        Uri = "$ImmichUrl/api/albums/$albumId"
        Method = "GET"
        Headers = $headers
    }
    
    $albumInvokeParams = $albumParams + $script:skipCertParams
    
    try {
        $albumDetail = Invoke-RestMethod @albumInvokeParams
        Write-Log -Message "앨범 정보 불러오기 성공: $($albumDetail.albumName)" -LogToFile

        $assetIds = $albumDetail.assets | Select-Object -ExpandProperty id
        
        if (-not $assetIds) {
            Write-Log -Message "✅ 자산이 없습니다. 삭제할 것이 없습니다." -ForegroundColor Green -LogToFile
            return
        }
        
        $count = $assetIds.Count
        Write-Log -Message "`n⚠️ 총 $count 개의 자산이 포함되어 있습니다." -LogToFile
        $confirm = Read-Host "정말 이 자산들을 삭제하시겠습니까? (yes 입력 시 진행)"
        
        if ($confirm -ne "yes") {
            Write-Log -Message "❌ 작업이 취소되었습니다." -LogToFile
            return
        }
        
        # https://immich.app/docs/api/delete-assets 참조
        Write-Log -Message "🗑️ 자산 일괄 삭제 중..." -ForegroundColor Yellow -LogToFile
        
        # 자산 ID 배열을 200개씩 나누어 처리 (API 제한 고려)
        $batchSize = 200
        $batches = [Math]::Ceiling($assetIds.Count / $batchSize)
        $totalDeleted = 0
        $failedCount = 0
        
        # 진행률 표시를 위한 초기화
        $progressParams = @{
            Activity = "자산 삭제 진행 중"
            Status = "0% 완료"
            PercentComplete = 0
        }
        Write-Progress @progressParams
        
        for ($i = 0; $i -lt $batches; $i++) {
            $startIdx = $i * $batchSize
            $endIdx = [Math]::Min(($i + 1) * $batchSize, $assetIds.Count) - 1
            $currentBatch = $assetIds[$startIdx..$endIdx]
            
            # 진행률 업데이트
            $percentComplete = [Math]::Min(100, [Math]::Floor(($i / $batches) * 100))
            $progressParams.Status = "$percentComplete% 완료"
            $progressParams.PercentComplete = $percentComplete
            Write-Progress @progressParams
            
            Write-Log -Message "배치 $($i+1)/$batches 처리 중: $($currentBatch.Count) 개 자산 삭제" -ForegroundColor Yellow -LogToFile
            
            # API 요청 본문 생성 (ids 배열과 force=true)
            $deleteBody = @{
                ids = $currentBatch
                force = $true
            } | ConvertTo-Json
            
            $deleteParams = @{
                Uri = "$ImmichUrl/api/assets"
                Method = "DELETE"
                Headers = $headers
                Body = $deleteBody
                ContentType = "application/json"
            }
            
            $deleteInvokeParams = $deleteParams + $script:skipCertParams
            
            $retryCount = 0
            $success = $false
            
            # 재시도 로직
            while (-not $success -and $retryCount -lt $maxRetries) {
                try {
                    Invoke-RestMethod @deleteInvokeParams | Out-Null
                    $totalDeleted += $currentBatch.Count
                    Write-Log -Message "✅ 배치 $($i+1) 삭제 완료 ($($currentBatch.Count)개 자산)" -ForegroundColor Green -LogToFile
                    $success = $true
                }
                catch {
                    $retryCount++
                    if ($retryCount -lt $maxRetries) {
                        Write-Log -Message "⚠️ 배치 $($i+1) 삭제 중 오류 발생: $($_.Exception.Message) - 재시도 중 ($retryCount/$maxRetries)..." -ForegroundColor Yellow -LogToFile
                        Start-Sleep -Seconds (2 * $retryCount)  # 지수적 백오프
                    }
                    else {
                        Write-Log -Message "❌ 배치 $($i+1) 삭제 실패 (최대 재시도 횟수 초과): $($_.Exception.Message)" -ForegroundColor Red -LogToFile
                        $failedCount += $currentBatch.Count
                    }
                }
            }
            
            # API 제한을 피하기 위한 대기
            if ($i -lt $batches - 1) {
                Write-Log -Message "다음 배치 처리 전 잠시 대기중..." -ForegroundColor Yellow -LogToFile
                Start-Sleep -Seconds 2
            }
        }
        
        # 진행률 표시 완료
        Write-Progress -Activity "자산 삭제 진행 중" -Completed
        
        # 삭제 결과 요약
        Write-Log -Message "`n📊 자산 삭제 결과" -ForegroundColor Cyan -LogToFile
        Write-Log -Message "- 처리된 자산 수: $count" -LogToFile
        Write-Log -Message "- 성공적으로 삭제된 자산 수: $totalDeleted" -ForegroundColor Green -LogToFile
        if ($failedCount -gt 0) {
            Write-Log -Message "- 삭제 실패한 자산 수: $failedCount" -ForegroundColor Red -LogToFile
        }
          
        Write-Log -Message "`n✅ 자산 삭제 작업 완료." -ForegroundColor Green -LogToFile
    }
    catch {
        Write-Log -Message "❌ 자산을 삭제하는데 실패했습니다." -ForegroundColor Red -LogToFile
        Write-Log -Message "오류 메시지: $($_.Exception.Message)" -ForegroundColor Red -LogToFile
    }
}

# === 실행 흐름 ===
$accessToken = Get-AccessToken
$albums = Get-Albums -token $accessToken

# 사용자에게 앨범 ID 입력받기
$selectedId = Read-Host "`n삭제할 앨범의 ID를 입력하세요"
$found = $albums | Where-Object { $_.id -eq $selectedId }

if (-not $found) {
    Write-Host "❌ 해당 ID의 앨범을 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}

Write-Host "🎯 선택한 앨범: $($found.albumName)"
# 앨범 자산 삭제 처리
Remove-AlbumAssets -token $accessToken -albumId $selectedId

# 앨범 자체 삭제 여부 확인 및 처리
Remove-AlbumItself -token $accessToken -albumId $selectedId
