## download
download : http://www.sublimetext.com

## 설치후 셋팅

- package control 설치 - 콘솔창을 오픈(Ctrl + `)하여 아래의 명령을 붙여넣어 실행

```
import urllib.request,os; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read())
```

Ctrl + Shift + P 를 눌러 command pallet를 열고 install package를 실행.

* Block Cursor Everywhere 설치
* Terminal 설치. : http://wbond.net/sublime_packages/terminal
* emmet : http://emmet.io/
* Git 설치.
* MarkdownEditing 설치: Markdown 과 MultiMarkdown에 맞는 테마와 문서를 손쉽게 작성할 수 있도록 해주는 부가 기능을 제공하는 플러그인 입니다.

### 마크다운 하이라이팅 설정

Preferences > Package Settings > Markdown Editing > Markdown Settings - User
 {"color_scheme": "Packages/Color Scheme - Default/Dawn.tmTheme"} 