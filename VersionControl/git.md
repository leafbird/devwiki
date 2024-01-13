## submodule

참조 : https://devocean.sk.com/blog/techBoardDetail.do?ID=165172&boardType=techBlog

#### 처음 연결하기

```shell
git submodule add git@github.com:user/sub-repo.git sub
```

.gitmodules, sub 폴더가 생긴다. 

```shell
git add .
git commit -m "feat: add submodules"
```

#### clone 하기

1) 서브모듈 초기화, 2) 서브모듈 업데이트 의 두 단계 과정을 추가로 거친다. 

```shell
git clone git@github.com:user/main-repo.git
git submodule init
git submodule update
```

clone하면서 한 번에 처리하려면 `--recurse-submodules` 사용.

```shell
git clone --recurse-submodules git@github.com:user/main-repo.git
```

#### 상태 확인 및 변경사항 적용

현재 상태 확인 (업데이트가 되었는지, 로컬 수정이 있는지, etc.)

```shell
git submodules status
```

업데이트된 submodule의 상태를 최신화 하기

```shell
git submodules update --remote
```