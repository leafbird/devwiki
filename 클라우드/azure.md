## 메타데이터 확인하기 (powershell)
참고 : https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/instance-metadata-service
```
    $res = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI http://169.254.169.254/metadata/instance?api-version=2019-03-11 -Method get;$res.compute
```

```
$headers = @{
    "Metadata" = "True"
}
Invoke-RestMethod -Method Get -Uri http://169.254.169.254/metadata/instance?api-version=2019-03-11 -Headers $headers | convertto-json -depth 20

```


## vm 복사하기

### 이미지 만들기
이미지를 만들기 전에, vm을 일반화 (generalize) 시켜서 특정 기기에 종속적이지 않은 상태로 만들어 주어야 한다. 일반화되지 않은 가상 머신에서 이미지를 만드는 경우, 해당 이미지에서 만든 가상 머신은 시작되지 않는다. 
https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/capture-image-resource

대략의 순서는 아래처럼 간다.
* 이미지로 만들 vm을 일반화한다. (일반화된 vm은 켜지지 않는다.)
* vm으로 '일반화된 이미지'를 만든다. 
* 위에서 만든 일반화된 이미지로 vm을 만든다 (https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/create-vm-generalized-managed)


### 디스크를 스냅샷 떠서 복사하기
위처럼 이미지를 만들면, 원본이었던 vm은 사용할 수 없게 된다. 복사하려는 vm이 계속 실행유지 되어야 한다면 위의 방식으로 하지 말고 스냅샷을 떠서 사본을 만든다. 
참고 : https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/create-vm-specialized#option-3-copy-an-existing-azure-vm

대략의 순서는 아래처럼 간다. 
* OS 디스크의 스냅샷을 만든다.
* 디스크 스냅샷을 이용해서 새 디스크를 만든다.
* 새로 만든 디스크를 이용해서 새 VM을 만든다.