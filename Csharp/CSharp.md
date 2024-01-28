## C#

### Collection vs Container
 * System.Collections.Generic
 * from http://www.slideshare.net/devcatpublications/c-c-8252982 김재석, C++ 프로그래머를 위한 C#, NDC2011, #34
 *  List<T>  -->  std::vector<T> 
 *  Queue<T>  -->  std::queue<T> 
 *  Stack<T>  -->  std::stack<T> 
 *  LinkedList<T>  -->  std::list<T> 
 *  Dictionary<TKey, TValue>  -->  std::map<Key, T> 
 *  HashSet<T>  -->  std::set<T> 
 
### file write

using (StreamWriter sw = new StreamWriter(abs_path_))
{
    sw.Write(CommentOutOf(info));
    sw.Flush();
    sw.Close();
}

### file readline

string line;
StreamReader sr = new StreamReader(RelPath);
while((line = sr.ReadLine()) != null)
{
    Console.WriteLine(line);
}

### StringBuilder (string stream)
from http://bubblogging.wordpress.com/2012/05/16/io-strings-memory-compression/
  public static void TestStringStreams()
  {
    StringBuilder sb = new StringBuilder();
    using (StringWriter sw = new StringWriter(sb))
    {
      sw.WriteLine("This is a test");
      sw.WriteLine("Hello, World");
    }

    using (StringReader sr = new StringReader(sb.ToString()))
    {
      string s;
      while ((s = sr.ReadLine()) != null)
      {
        Console.WriteLine(s);
      }
    }
  }

### string format align (formatting)
  Console.WriteLine("-------------------------------");
  Console.WriteLine("First Name | Last Name  |   Age");
  Console.WriteLine("-------------------------------");
  Console.WriteLine(String.Format("{0,-10} | {1,-10} | {2,5}", "Bill", "Gates", 51));
  Console.WriteLine(String.Format("{0,-10} | {1,-10} | {2,5}", "Edna", "Parker", 114));
  Console.WriteLine(String.Format("{0,-10} | {1,-10} | {2,5}", "Johnny", "Depp", 44));
  Console.WriteLine("-------------------------------");

### exif

 * c#에서 exif 읽기 : http://www.developerfusion.com/article/84474/reading-writing-and-photo-metadata/
 * 처음엔 2.0버전 api가 있고, 이후에 3.0버전 api가 있다. 뒤에 것을 사용할 것.
 * http://stackoverflow.com/questions/180030/how-can-i-find-out-when-a-picture-was-actually-taken-in-c-sharp-running-on-vista
 
### linq

```
using System.Linq;

// List에 담긴 객체의 특정 멤버 변수만을 추출
List<DataField> fields = new List<DataField>();
var names = fields.Select(d => d.Name).ToArray();

// 필터링
var names = fields
    .Where(d => d.DefaultValue != null)
    .Select(d => d.Name)

// List에 담긴 객체의 멤버함수가 모두 True를 반환하는지 확인
if (fields.TrueForAll(d => d.IsBasicType()))
{
    // ...
}
```

### 부동소수점 포매팅 floating-point formatting

```
    Console.WriteLine("float : {0:.00}", 12.3456);
```

### 폴더 & 파일 순회 directory & file traverse 

```
    string root = "blah";
    DirectoryInfo info = new DirectoryInfo(root);
    List<FileInfo> files = info.GetFiles("*.cpp", SearchOption.AllDirectories).ToList();
    
    foreach (string fileName in files.Select(i => i.FullName))
    {
        Console.WriteLine("file:{0}", fileName);
    }
```

### 실행파일 이름 executable name

```
    Process.GetCurrentProcess().ProcessName
```

### 정규표현식 Regex
msdn reference : http://msdn.microsoft.com/en-us/library/az24scfc(v=vs.110).aspx

C#의 정규표현식으로 한글을 아무 문제없이 검사할 수 있다. 

```
    [가-힣]{2,5} : 한글 최소 2~5글자 입력가능
```

```
using System;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
	// First we see the input string.
	string input = "/content/alternate-1.aspx";

	// Here we call Regex.Match.
	Match match = Regex.Match(input, @"content/([A-Za-z0-9\-]+)\.aspx$",
	    RegexOptions.IgnoreCase);

	// Here we check the Match instance.
	if (match.Success)
	{
	    // Finally, we get the Group value and display it.
	    string key = match.Groups[1].Value;
	    Console.WriteLine(key);
	}
    }
}
```

### Reflection : 특정 인터페이스를 상속받았는지 여부를 조회
```
      if (data_type.GetInterface("ICustomType") != null) {
        foreach (PropertyInfo property_info in data.GetType().GetProperties()) {
          Put(property_info.GetValue(data, null));
        }
      }
```

### 강제로 디버거 띄우기

```
  System.Diagnostics.Debugger.Launch();
```