## confluence api v2

페이지를 만들 때 오류가 발생하는데, 보안상의 이유 떄문인지 html tag가 쓰인 페이지 본문은 api가 받아들지이 않고 'BadRequest'를 반환한다. 

html을 escaping하면 페이지는 업데이트 되지만, 눈으로 읽기 힘든 페이지가 만들어져 의미가 없다. 

update할 때 내용의 형식을 정의해줄 수 있는데, wiki로 만들면 html 대신 위키 문법으로 마크업을 할 수 있다. 

참고 : https://confluence.atlassian.com/doc/confluence-wiki-markup-251003035.html

> As with wiki markup, Confluence will convert your markdown to the rich text editor format. 
> You will not be able to edit your content using markdown.

페이지에서 에디터를 이용해 직접 글을 쓸 때 markdown을 이용할 수는 있으나 바로 변환시키는 듯.