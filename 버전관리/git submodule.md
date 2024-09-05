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

1) 서브모듈 초기화, 2) 서브모듈 업데이트의 두 단계 과정을 추가로 거친다. 

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


```shell
# 현재 상태 확인 (업데이트가 되었는지, 로컬 수정이 있는지, etc.)
git submodule status

# 업데이트된 submodule의 상태를 최신화 하기
git submodule update --remote
```

#### 제거하기

1. .gitmodules 파일에서 해당 submodule 섹션을 제거합니다.
1. .git/config 파일에서 해당 submodule 섹션을 제거합니다.
1. Git 캐시에서 submodule을 제거합니다.
1. submodule의 디렉토리를 제거합니다.

```shell
# .gitmodules에서 submodule 제거
git config -f .gitmodules --remove-section submodule.<submodule_name>

# .git/config에서 submodule 제거
git config --remove-section submodule.<submodule_name>

# Git 캐시에서 submodule 제거
git rm --cached <submodule_path>

# submodule 디렉토리 제거
rm -rf <submodule_path>

# 변경사항 커밋
git commit -m "Removed submodule <submodule_name>"
```