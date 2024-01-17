## vhdx 파일 사이즈 줄이는 법

참고 : http://archmond.net/?p=2754
- http://honajang-textcube.blogspot.com/2010/01/sdelete%EB%A1%9C-vhd-%ED%8C%8C%EC%9D%BC-%EC%9A%A9%EB%9F%89-%EC%A4%84%EC%9D%B4%EA%B8%B0.html

```
- 관리자 권한으로 command prompt 실행
> diskpart
diskpart> select vdisk file=vhd파일경로
diskpart> attach vdisk
diskpart> list vol - VHD가 로드된 드라이브명 확인
diskpart> exit
> sdelete -z 드라이브명:
> diskpart
diskpart> select vdisk file=vhd파일경로
diskpart> detach vdisk
diskpart> compact vdisk
```

