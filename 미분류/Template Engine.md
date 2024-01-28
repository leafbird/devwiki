++ Template Engine

2013년 GDC의 명 강연이었던 'Network Serialization and Routing in World of Warcraft' 를 다시 보았다.
패킷 생성 과정에 템플릿 엔진을 넣을 생각을 한게 아주 신박하다. 
dJango를 보고 아이디어가 생각났다는데, 누구는 옛날 만화영화를 생각하는데 누구는 저런걸 생각하는군. 대단해.

pt자료에서 추천한 템플릿 엔진들을 먼저 좀 봤는데, 결국은 언어의 문제. CTemplate은 깔끔하니 괜찮아 보였지만 (구글이 만들었기도 하고)
C++로 툴을 만드는 건 별로인 듯. 그래서 툴 만들기 좋은 C# 엔진을 찾아보는 중이다. 

T4, String Template(from ANTLR), Razor Engine 정도를 살펴보았는데, 현재로는 Razor가 제일 나은 듯.

T4는 빌드 타임에 코드를 생성하는 것에 특화되어 있어서, 패킷 제네레이션에 쓸 수 있을까도 좀 의문이고,
String Template은 ANTLR이라는 파서에 들어있는 녀석인데... 파서 친화적이랄까. 템플릿 규칙 정의하는데도 expression tree 같은걸 정의해야 하고 해서 복잡해 보인다.
Razor는 ASP.NET 개발할 때 쓰라고 만들어진 물건 같은데... 둘러본 엔진들 중에서는 가장 쓰기 편할 듯. loop를 편하게 for문으로 돌 수 있는 것도 맘에 든다. 

몇가지 더 둘러보고 딱히 눈에 들어오는 것 없으면 일단 Razor를 파보자.

둘러보려 했던 .NET Template Engine ( http://www.componentpro.com/templateengine.net/ ) 은 상용! 쿨하게 패스.

블리자드 발표자료에서 ANTLR을 언급. 닥치고 ANTLR 판다.

http://www.antlr.org/wiki/display/ST4/Introduction
http://stackoverflow.com/questions/2410935/stringtemplate-net-dynamic-object
http://www.ksug.org/105
http://sonegy.wordpress.com/2012/04/04/stringtemplate-4-0-%ED%99%9C%EC%9A%A9/
http://sonegy.wordpress.com/2012/02/08/stringtemplate-4-0-%EC%86%8C%EA%B0%9C/

```
using Antlr4.StringTemplate;

private static void Antlr4Test()
{
    Template tmp = new Template("Hello, <name>");
    tmp.Add("name", "World");
    Console.WriteLine(tmp.Render());
}
```