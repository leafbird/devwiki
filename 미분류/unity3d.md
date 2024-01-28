

## git 설정하기

(Skip this step in v4.5 and up) Enable External option in Unity → Preferences → Packages → Repository.
Switch to Visible Meta Files in Edit → Project Settings → Editor → Version Control Mode.
Switch to Force Text in Edit → Project Settings → Editor → Asset Serialization Mode.
Save the scene and project from File menu.

## sln 파일 생성하기 
출처 : https://forum.unity.com/threads/any-way-to-tell-unity-to-generate-the-sln-file-via-script-or-command-line.392314/

```
Unity.exe  -batchmode -nographics -logFile - -executeMethod UnityEditor.SyncVS.SyncSolution -projectPath . -quit
```

## [InitializeOnLoad] 에디터에서 코드로딩 할 때마다 수행하는 로직
출처 : https://blog.daum.net/arkofna/18283205

* 스크립트 수정&저장하고 나서 유니티에서 로드가 끝나면 바로 콘솔창에 나타난다.
* 유니티를 껏다 켜도 바로 콘솔창에 나타난다.

-> 스크립트를 로드하면서 해당 내용이 있으면 작동이 되는 것으로 보인다.
--> 다른 스크립트를 작성해서 로드되어도 표시된다.

## 시스템 로그 가로채기
출처 : https://yatanasov.com/2016/07/26/recreating-the-unity-console-part-i/

