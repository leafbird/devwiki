## asp.net에서 fire and forget 처리

- http://walkingthestack.blogspot.kr/2015/05/small-tip-use-queuebackgroundworkitem.html
- https://msdn.microsoft.com/en-us/library/dn636893%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396
- async void in ASP.NET : http://stackoverflow.com/questions/17659603/async-void-asp-net-and-count-of-outstanding-operations
- https://blog.mariusschulz.com/2014/05/07/scheduling-background-jobs-from-an-asp-net-application-in-net-4-5-2

## webdeploy, 배포, deploy.cmd ... 게시를 zip 파일로 했을 때, 자동배포하기
- 기존의 로컬 변경을 지우지 않고 싶을 때 
출처 : http://forums.iis.net/t/1164755.aspx?Avoid+MSdeploy+package+deleting+all+target+files

    "-enableRule:Donotdeleterule" 를 인자로 넣는다. 따옴표 꼭 넣어야 함.

- 배포할 대상을 지정하려면
출처 : https://msdn.microsoft.com/en-us/library/ff356104(v=vs.110).aspx
개발망은 인터넷 연결이 안되기 때문에 기본 배포되는 WebDeploy만 사용가능. 이럴 때 쓸 수 있는 옵션이 Web Deployment Agent Service (MSDepSvc) 부분이다.
실행 인자에는 아래처럼 넣어서 컴퓨터 까지만 지정한다.
    ProjectName.deploy.cmd /t /m:http://DestinationServerName/MSDeployAgentService
배포 파일과 같은 경로에 생성된 `SetParameters.xml`에서 응용 프로그램 풀과, 풀 하위의 추가 응용 프로그램 경로를 지정해준다.
응용 프로그램만 지정하려면
    <setParameter name="IIS Web Application Name" value="nv_main" />
응용 프로그램및 하위 프로그램까지 지정하려면
    <setParameter name="IIS Web Application Name" value="nv_main/nv" />


## asp.net 사이트가 처음 뜰 때 느린 것 완화 설정
출처 : http://aspnetfaq.com/iis7-application-pool-idle-time-out-settings/ 외 다수.

- application pool 고급설정에서 '시작모드' 를 AlwaysRunning으로 변경
- application pool 고급설정에서 '유휴시간 제한'을 0으로 변경
- application pool '재생...' 설정에서 '표준시간 간격'을 체크 해제. (및 불필요한 설정은 모두 해제)

## asp.net application pool 안에 들어있는 잘못된 application을 지우고 싶을 때
출처 : http://stackoverflow.com/questions/25814925/how-are-applications-removed-from-the-iis-application-pool

    appcmd delete app eng_app/drawing


## asp and async void
http://stackoverflow.com/questions/28805796/asp-net-controller-an-asynchronous-module-or-handler-completed-while-an-asynchr
http://stackoverflow.com/questions/17659603/async-void-asp-net-and-count-of-outstanding-operations

## iis_express를 64bit로 실행하는 법

출처 : http://www.johandorper.nl/log/iis-64-bit-mode-with-edit-and-continue

1. Start Visual Studio and click on Tools -> Options.
2. From the tree: Projects and Solutions, then Web Projects.
3. And make sure that Use the 64 bit version of IIS Express for web sites and projects is checked (press OK)

## 아 놔 별 개그지같은... razor intellisense 안될 때 해결하는 법

출처 : http://stackoverflow.com/questions/30311355/visual-studio-2015-not-syntax-highlighting-razor-nor-intellisense

Just delete the contents of this directory with Visual Studio closed: 
    %LocalAppData%\Microsoft\VisualStudio\14.0\ComponentModelCache

## 라우팅 할 때 '/'도 포함해서 변수로 받아내는 법

출처 : http://stackoverflow.com/questions/6328713/urls-with-slash-in-parameter

```
routes.MapRoute(
    "Wiki",
    "wiki/{*id}",
     new { controller = "Wiki", action = "DbLookup", id = UrlParameter.Optional }
);
```

## site root 얻는 법

출처 : http://stackoverflow.com/questions/5853294/how-do-i-get-the-site-root-url

Using MVC:
    HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + Url.Content("~/")
or, if you are trying to use it directly in a Razor view:
    @HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority)@Url.Content("~/")

## site root에 해당하는 파일 시스템 상의 경로를 얻어오는 법
```
  string server_path = Server.MapPath("~");
```

## 특정 확장자에 대한 라우팅을 intercept하는 방법

출처 : http://weblogs.asp.net/jongalloway/asp-net-mvc-routing-intercepting-file-requests-like-index-html-and-what-it-teaches-about-how-routing-works


1. Adding a handler mapping is really easy - just open up your web.config and add it to the <system.webServer/handlers> node.

<add name="HtmlFileHandler" path="*.html" verb="GET" type="System.Web.Handlers.TransferRequestHandler" preCondition="integratedMode,runtimeVersionv4.0" />
Note that you can make the path more specific if you'd like. For instance, if you only wanted to intercept one specific request, you could use path="sample.html"

Step 2. Configuring the route
Next, you'll need a new route. Open up App_Start/RouteConfig.cs and it to the RegisterRoutes call. My complete RegisterRoutes looks like this:

routes.MapRoute(
    name: "CrazyPants",
    url: "{page}.html",
    defaults: new { controller = "Home", action = "Html", page = UrlParameter.Optional }
);
You can make your route as complex as you want. For instance, here's one by pilotbob which uses a constraint to map several legacy filetypes to a controller:

routes.MapRoute(
    "Legacy"
    , "Html/{*src}"
    , new { Controller = "Home", action = "Html" }
    , new { src = @"(.*?)\.(html|htm|aspx|asp)" }                     // URL constraints
    , new [] { "WebApp.Controllers" }
);

## ViewBag에 글로벌한 값을 설정하는 법

출처 : http://stackoverflow.com/questions/5453327/how-to-set-viewbag-properties-for-all-views-without-using-a-base-class-for-contr

The best way is using ActionFilterAttribute and register your custom class in your global. asax (Application_Start)

public class UserProfilePictureActionFilter : ActionFilterAttribute
{

    public override void OnResultExecuting(ResultExecutingContext filterContext)
    {
        filterContext.Controller.ViewBag.IsAuthenticated = MembershipService.IsAuthenticated;
        filterContext.Controller.ViewBag.IsAdmin = MembershipService.IsAdmin;

        var userProfile = MembershipService.GetCurrentUserProfile();
        if (userProfile != null)
        {
            filterContext.Controller.ViewBag.Avatar = userProfile.Picture;
        }
    }

}
register your custom class in your global. asax (Application_Start)

protected void Application_Start()
    {
        AreaRegistration.RegisterAllAreas();

        GlobalFilters.Filters.Add(new UserProfilePictureActionFilter(), 0);

    }
Then you can use it in all views

@ViewBag.IsAdmin
@ViewBag.IsAuthenticated
@ViewBag.Avatar