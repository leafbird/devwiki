## 240114

dotnet-script readme를 더 읽어보니 csx 파일 그 자체로 nuget 배포가 가능하다. 굳이 git submodule을 이용해서 재사용 처리할 필요가 없다. 

csx에서 sitemap maker를 만들어보고 있다. 디버깅도 지원되고 인텔리센스도 지원되지만, 일반적인 csproj 환경보다는 많이 열악하다. 컴파일 에러를 확인하려면 직접 실행해봐야만 알 수 있다. 

* 스타일캅을 지원하지 않는다. 혹시 방법이 있는데 내가 아직 모르고 있는 것인가?
* 오타가 있을 때 빨간줄로 미리 알려주지 않는다. 
* BCL의 함수를 사용하는데, 자동완성 목록에 모든 메서드 리스트가 다 뜨지 않는다. 

일단 두시간 정도 작업하니 그럴싸한 아웃풋이 나온다.

```shell
$ ./SitemapMaker/main.csx ./devwiki/README.md
## Categories

* [VersionControl](#versioncontrol)
* [TIL](#til)

---

### VersionControl

* [git.md](/Users/florist/dev/devwiki/VersionControl/git.md)

### TIL

* [240113.md](/Users/florist/dev/devwiki/TIL/240113.md)
* [240114.md](/Users/florist/dev/devwiki/TIL/240114.md)

```

## todo

* [x] 실제 readme.md로 출력
* [x] 파일 링크 경로 제대로 교정하기
* [x] readme.md에 주석으로 generated 영역 구분하고, 수동으로 적은 컨텐츠 살리기