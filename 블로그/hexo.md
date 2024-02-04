## image 경로 자동 보정 설정

참조 : https://hexo.io/docs/asset-folders.html

hexo-renderer-marked 3.1.0부터 들어간 기능. 마크다운 문법으로 이미지를 출력하면 알아서 어셋폴더의 경로로 resolve해준다. 아래의 설정으로 활성화 한다. 

```yaml
post_asset_folder: true
marked:
  prependRoot: true
  postAsset: true
```

`post_asset_folder`는 예전부터 있던 설정(포스트별로 분리된 어셋 폴더 공간을 사용한다는 설정)이고, marked 하위 설정을 추가하면 기능이 켜진다. 