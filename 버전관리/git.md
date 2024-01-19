## Git

 * [local git server]
 * Pro Git 한글 번역 : http://git-scm.com/book/ko
 * [_netrc]

### 새로운 리모트 저장소 추가

    git remote add remoteName https://....git

### 원본 저장소 수정사항을 내가 fork한 저장소에 반영하기

 1. 원본 -> 로컬 : git pull remoteName
 = git fetch remoteName + git merge remoteName
 1. 로컬 -> fork된 저장소 : git push (origin)

### branch

 * git branch : 현재 존재하는 브랜치 리스트 확인. 
 * git branch --remote : 리모트에 존재하는 브랜치 리스트 확인.
 * git checkout <name> : 사용하는 브랜치 이동.
  * git checkout -b <name> : 브랜치 생성과 동시에 이동.
  * git checkout -b <name> origin/<name> : 로컬에 pull되어있는 리모트 브랜치를 추적하는 로컬 브랜치를 생성하면서 바로 이동.
 * git branch -d <name> : 브랜치 삭제.
 * git push origin --delete <branchName> : 리모트 브랜치 삭제
 * git push origin :<branchName> : 리모트 브랜치 삭제
 * git fetch -p : 리모트 브랜치를 지웠는데도 git branch --remote 목록에 계속 나타나는 걸 정리하고 싶으면 실행.
 * git pull : 리모트 브랜치와 동기화 하려면 pull.
 
### github : default branch 이름 master -> main 변경

깃헙 사이트 설정에서 main으로 이름 변경 후, 로컬 브랜치 있는 머신에서 아래 명령 실행

```
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
git fetch -p # 삭제는 됐지만 로컬에서 여전히 리모트 브랜치 목록이 보이는 것을 정리해준다.
git branch --remote
```

### merge

dev에서 작업한 내용을 master에 merge하려면
```
    git checkout master
    git merge dev
    
    혹은 
    
    git merge dev master (이렇게 하면 master로 자동 checkout된다)
```
충돌이 생기면 직접 수동으로 해결하거나 git mergetool.

### rebase

rebase 상황까지 왔다면 commit tree(?)를 비주얼하게 볼 필요성이 있을것이다. 이럴 땐 gitk가 도움이 될 것이다. context menu에서 gith history를 선택하면 실행된다. 
기본 설명은 [http://git-scm.com/book/ko/Git-%EB%8F%84%EA%B5%AC-%ED%9E%88%EC%8A%A4%ED%86%A0%EB%A6%AC-%EB%8B%A8%EC%9E%A5%ED%95%98%EA%B8%B0|Git-도구-히스토리-단장하기] 가 도움이 될것이다. 
비주얼한 튜토리얼은 http://learnbranch.urigit.com/ 가 좋다. 
위 모든 내용을 알게 해준 블로그 [http://www.letmecompile.com/git-%EC%83%81%ED%99%A9%EB%B3%84-%EB%AA%85%EB%A0%B9%EC%96%B4-tips/|git-상황별-명령어-tips] 도 좋다. 

    git rebase -i HEAD~3

위 명령은 최근 3개 commit에 대한 대화형 수정을 시작한다. 오픈된 에디터에는 오래된 commit이 제일 위에 보인다. 
commit 앞의 키워드를 squash로 변경하면 이전의 commit에 합쳐진다. 

### OS X

컬러 설정 : http://stackoverflow.com/questions/1156069/how-to-configure-term-on-mac-os-x-with-color

### history

바로 이전 commit을 수정하고 싶을 때. description을 수정하거나 누락된 파일을 함께 다시 올리고 싶은 경우

 git commit --amend

### stash

참조 : http://git-scm.com/book/ko/v1/Git-%EB%8F%84%EA%B5%AC-Stashing

작업내용을 임시 공간에 유지하고, 현재 작업 공간을 비워준다.

    git stash : 현재 수정사항을 stashing
    git stash list : stash된 내용을 리스트로 보여준다.
    git stash apply : stash된 내용을 복원한다. 
    git stash apply --index : staged상태까지 복원한다.


 ### export 

path 뒤에 마침(\) 처리 꼭 해주어야 한다!
git checkout-index -a -f --prefix=/destination/path/

## .gitignore에 뒤늦게 추가한 패턴의 파일이 이미 저장소에 들어 있을 때, 잊게 하는 법

출처 : http://stackoverflow.com/questions/1274057/making-git-forget-about-a-file-that-was-tracked-but-is-now-in-gitignore

```
git rm --cached <file>
```


## clean 
untracked 파일을 정리하고 싶을 때

    git clean -d -f

* -d : 디렉토리도 삭제하기.
* -f : force. 넣지 않으면 지워지지 않는다. 