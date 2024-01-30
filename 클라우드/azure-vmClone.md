# Azure VM clone

vm을 복사하는 데 여러가지 방법이 있다. 

1. vm을 일반화(종료됨) -> vm 이미지 생성(기존vm 삭제) -> 이미지에서 vm 생성
2. disk os에서 스냅샷 생성 -> 새로운 disk os 생성 -> 새 disk os 사용하는 vm 생성
3. ...etc. 말고도 많음.



## vm 이미지 만들기

https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/capture-image-resource

#### 1. 일반화 시키기 

원격 접속해서 관리자 권한으로 실행

```
cd %windir%\system32\sysprep
sysprep.exe
```

![](https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/media/upload-generalized-managed/sysprepgeneral.png)

1. 위에 Generalize에 체크
2. 아래 Shutdown Options : Shutdown으로 변경하고 확인. 

...vm이 꺼진 후 다시 켜지지 않는다.



#### 2. 이미지 생성

```powershell
# 일부 변수를 만듭니다.
$vmName = "vm-copied"
$rgName = "RG-COUNTERSIDEDEV"
$location = "koreacentral"
$imageName = "vm-image-200823"

# VM의 할당이 취소되었는지 확인합니다.
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

# 가상 머신의 상태를 일반화됨으로 설정합니다.
Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

# 가상 머신을 가져옵니다.
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

# 이미지 구성을 만듭니다.
$image = New-AzImageConfig -Location $location -SourceVirtualMachineId $vm.Id -HyperVGeneration V2 -OsDisk

# 이미지를 만듭니다.
New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $rgName
```



#### 3. 이미지에서 vm 만들기

```powershell
# 일부 변수를 만듭니다.
$imageName = "vm-image-200823"
$vmName = "vm-createTest"

$rgName = "RG-COUNTERSIDEDEV"
$location = "koreacentral"
$securityGroupName = "CTS-ST-FIREWALL"
$virtualNetworkName = "RG-CounterSideDev-vnet"

New-AzVm `
    -ResourceGroupName "RG-COUNTERSIDEDEV" `
    -Name $vmName `
    -ImageName $imageName `
    -Location $location `
    -VirtualNetworkName $virtualNetworkName `
    -SubnetName "default" `
    -SecurityGroupName $securityGroupName `
    -PublicIpAddressName "$vmName-ip" `
    -Size "Standard_B2ms"
```



## disk os 스냅샷으로 만들기

https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/create-vm-specialized#option-3-copy-an-existing-azure-vm



```powershell
## os disk의 스탭샷 만들기

# 일부 매개 변수를 설정합니다.
$resourceGroupName = 'RG-COUNTERSIDEDEV' 
$vmName = 'vm-china'
$location = 'koreacentral' 
$snapshotName = 'disk-snapshot'

# VM 개체를 가져옵니다.
$vm = Get-AzVM -Name $vmName `
   -ResourceGroupName $resourceGroupName

# OS 디스크 이름을 가져옵니다.
$disk = Get-AzDisk -ResourceGroupName $resourceGroupName `
  -DiskName $vm.StorageProfile.OsDisk.Name

# 스냅샷 구성을 만듭니다.
$snapshotConfig =  New-AzSnapshotConfig `
  -SourceUri $disk.Id `
  -OsType Windows `
  -CreateOption Copy `
  -Location $location

# 스냅샷을 만듭니다.
$snapShot = New-AzSnapshot `
   -Snapshot $snapshotConfig `
   -SnapshotName $snapshotName `
   -ResourceGroupName $resourceGroupName

### 스냅샷에서 새 디스크 만들기

# OS 디스크 이름을 설정합니다.
$osDiskName = 'vm-copied-disk'

# 관리 디스크를 만듭니다.
$osDisk = New-AzDisk -DiskName $osDiskName -Disk `
    (New-AzDiskConfig  -Location $location -CreateOption Copy `
    -SourceResourceId $snapshot.Id) `
    -ResourceGroupName $resourceGroupName
```



이렇게 만들면 os disk가 standrad HDD가 되는데,

standard ssd 설정 옵션은 없고 premium ssd만 있는 듯 하다. 



보다 상세한 예시 참고 : https://www.magrin.one/create-a-vm-from-powershell.html