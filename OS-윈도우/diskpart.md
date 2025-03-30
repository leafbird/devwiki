# 우분투 설치디스크를 다시 ntfs로 포맷하기

```pwsh
# diskpart 실행

list disk # 디스크 목록 확인
select disk x # x는 포맷할 디스크 번호
clean # 디스크 초기화

create partition primary
format fs=ntfs quick

선택한 볼륨이 없습니다.
볼륨을 선택하고 다시 시도해 보십시오.

exit
```

포맷은 진행되지 않는다. 탐색기에서 우클릭해서 포맷 진행하면 된다. 