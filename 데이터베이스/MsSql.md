## Ms Sql

#### odbc : bind selected data column with name
 참조 : http://www.easysoft.com/developer/languages/c/examples/DescribeAndBindColumns.html

#### odbc : named parameter
 출처 : https://msdn.microsoft.com/en-us/library/ms715435%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396

    // Prepare the procedure invocation statement.
    SQLPrepare(hstmt, "{call test(?)}", SQL_NTS);
    
    // Populate record 1 of ipd.
    SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR,
                      30, 0, szQuote, 0, &cbValue);
    
    // Get ipd handle and set the SQL_DESC_NAMED and SQL_DESC_UNNAMED fields
    // for record #1.
    SQLGetStmtAttr(hstmt, SQL_ATTR_IMP_PARAM_DESC, &hIpd, 0, 0);
    SQLSetDescField(hIpd, 1, SQL_DESC_NAME, "@quote", SQL_NTS);
    
    // Assuming that szQuote has been appropriately initialized,
    // execute.
    SQLExecute(hstmt);

#### find blocking

http://blog.matticus.net/2014/11/troubleshooting-blocking-locks-in-sql.html

#### azure performance query
http://blog.liamcavanagh.com/2013/06/how-to-perform-sql-azure-performance-diagnostics-analysis-for-sql-azure/

### query store

https://msdn.microsoft.com/en-US/library/dn817826.aspx
https://azure.microsoft.com/ko-kr/blog/query-store-a-flight-data-recorder-for-your-database/

### .bacpac 파일에서 복원하기

출처 : http://stackoverflow.com/questions/27850337/how-to-import-azure-sql-backup-bacpac-to-localdb-using-visual-studio

SqlPackage.exe를 사용한다. 아래 경로에 있다. 
    C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120

인자는 아래를 참고한다.
    .\SqlPackage.exe /Action:Import /SourceFile:"d:\profile\downloads\ksj-db.bacpac" /TargetConnectionString:"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ksj-main; Integrated Security=true;"

### 시스템 기본제공 프로시저들

 * sp_helpdb <dbname> : 데이터 베이스 정보 확인.
 * sp_spaceused <tablename> : 테이블 row 개수 및 용량 관련 정보 확인.

### 테이블 데이터 개수 얻어오기

출처 : http://blogs.msdn.com/b/martijnh/archive/2010/07/15/sql-server-how-to-quickly-retrieve-accurate-row-count-for-table.aspx

무난한 타협점은 아래 쿼리인 듯.

```
SELECT SUM (row_count)
FROM sys.dm_db_partition_stats
WHERE object_id=OBJECT_ID('Transactions')   
AND (index_id=0 or index_id=1);
```

sp_spaceused '테이블명' 방법도 있다.

## 인덱스 설정 지침

출처 : http://junyoungs.blogspot.kr/2013/07/blog-post_10.html

인덱스를 선택하는 것은 많은 SQL Server DBA와 개발자에게 신비로운 대상이다. 물론 우리는 인덱스가 어떤 일을 하며 어떻게 성능을 향상시키는지를 잘 알고 있다. 문제는 이상적인 인덱스 종류와(클러스터드 vs. 넌클러스터드), 인덱스에 포함시킬 컬럼의 개수(다중 컬럼 인덱스가 필요한지 여부), 그리고 어떤 컬럼에 인덱스를 만들 것이냐 하는 점이다.

여기서는 이 질문에 대한 답변을 간략하게 제공하고자 한다. 불행하게도, 각각의 경우에 대한 절대적인 해답은 존재하지 않는다. 다른 성능 튜닝 및 최적화와 마찬가지로 이상적인 인덱스를 찾으려면 직접 테스트하는 수고를 감수해야 한다. 이제 인덱스 생성에 있어서의 보편적인 지침을 먼저 살펴보고 다음에는 클러스터드 인덱스와 넌클러스터드 인덱스를 선택하는 기준에 대해서 자세히 알아보도록 하겠다.


인덱스가 너무 많아서 문제가 될 수도 있는가?

정답은 “그렇다” 이다. 어떤 사람들은 모든 컬럼에 인덱스를 걸면 성능 문제가 모두 해결될 것이라고 생각하기도 하는데 실제로는 전혀 그렇지 않다. 인덱스가 데이터 액세스 속도를 증가시키는 것과 마찬가지로 잘못 선택하면 오히려 액세스 속도를 저하시킬 수도 있다. 인덱스가 많음으로 해서 발생하는 문제는 INSERT, UPDATE, DELETE가 발생할 때 마다 SQL Server가 인덱스를 유지하기 위한 작업을 해야만 한다는 것이다. 하나의 테이블에 한 두개 정도의 인덱스를 관리하는 것은 SQL Server가 처리하기에 별 부담이 없지만 네 개, 다섯 개 혹은 그 이상의 인덱스를 만들게 되면 성능에 큰 장애 요인으로 작용하게 된다. 가능하다면 인덱스를 적게 만드는 것이 좋으며 최적의 성능을 얻기 위해서 적절한 개수의 인덱스를 만드는 것이 요구된다.

단지 인덱스를 추가하는 것이 좋을 것 같다는 생각만으로 무조건 인덱스를 만드는 것은 좋지 않다. 해당 테이블을 이용하는 쿼리에서 사용될 것이 확실한 경우에만 인덱스를 추가해야 한다. 어떤 쿼리가 실행될지 알 수 없다면 확실히 알기 전까지는 아무 인덱스도 만들지 않는 편이 낫다. 어떤 쿼리가 실행될지 추측하고, 거기에 따라서 인덱스를 생성하면 결국 애초의 추측이 틀렸음을 알게 되는 경우가 많기 때문이다. 실행될 쿼리의 유형을 먼저 알아야 하고 그 다음에 가장 적절한 인덱스를 만들기 위한 분석 과정을 거친 후에야 비로소 인덱스를 생성하고 실제로 효과가 있는지 테스트 해야 한다.
OLTP 프로그램은 INSERT, UPDATE, DELETE 작업이 매우 많기 때문에 최적의 인덱스를 선택하기 위한 판단을 내리기가 쉽지 않다. SELECT, UPDATE, DELETE 할 레코드를 신속하게 찾기 위해서는 인덱스가 필요하지만 인덱스가 너무 많으면 INSERT, UPDATE, DELETE 작업이 실행될 때 과도한 오버헤드가 발생하게 된다. 한편, 주로 읽기 작업이 많은 OLAP 프로그램의 경우에는 INSERT, UPDATE, DELETE 작업에 대해서 걱정할 필요가 없기 때문에 필요한 만큼 인덱스를 만들어도 상관 없다. 이와 같이 인덱스 전략을 수립할 때에는 응용프로그램이 어떻게 사용될 것인가가 큰 차이를 가져오게 된다.

인덱스를 선택할 때 고려해야 할 사항을 하나 더 들자면 선택한 인덱스가 SQL Server 쿼리 옵티마이저에 의해서 사용되지 않을 수도 있다는 점이다. 쿼리 옵티마이저가 인덱스를 사용하지 않기로 결정하였다면 인덱스는 SQL Server에게 부담이 될 뿐이기 때문에 아예 삭제하는 편이 낫다. 그렇다면 SQL Server 쿼리 옵티마이저에서 인덱스가 존재함에도 항상 인덱스를 사용하지는 않는 이유는 무엇일까?
여기서 자세하게 답변하기에는 너무 광범위한 내용이지만 한마디로 요약하자면 SQL Server가 인덱스를 사용하는 것 보다 테이블 검색을 수행하는 편이 더 빠르다고 판단하는 경우가 있기 때문이라고 할 수 있다. 여기에는 두 가지 경우가 있는데 하나는 테이블의 크기가 작은 경우이고(레코드 수가 적음) 또 다른 하나는 인덱스가 걸린 컬럼의 유일한 값이 95%보다 적기 때문이다. SQL Server가 인덱스를 사용하지 않을지를 어떻게 알 수 있을까? 이에 대한 답변은 SQL Server 쿼리 애널라이저를 사용하는 방법을 살펴본 다음에 알아보기로 하겠다.
클러스터드 인덱스를 선택하는 방법
하나의 테이블에는 하나의 클러스터드 인덱스만을 만들 수 있기 때문에 어떻게 사용할 것인가를 신중하게 생각해야 한다. 실행할 쿼리의 유형을 고려해 보고 어떤 쿼리가 가장 중요하며 클러스터드 인덱스를 사용했을 때 도움이 될지를 추정해 보도록 한다.

일반적으로는 클러스터드 인덱스를 만들 컬럼을 선택할 때에는 다음과 같은 기준을 사용한다.
테이블의 프라이머리 키를 항상 클러스터드 인덱스로 만들어서는 안 된다. 프라이머리 키를 만든 다음에 특별히 지정을 하지 않으면 SQL Server는 자동으로 프라이머리 키를 클러스터드 인덱스로 만든다. 프라이머리 키가 다음과 같은 조건에 부합될 경우에만 클러스터드 인덱스로 만들도록 한다.
클러스터드 인덱스는 일정한 범위의 값에 대해서 쿼리를 실행하거나 정렬된 결과를 필요로 할 ‘때 가장 좋은 방법이다. 왜냐하면 데이터가 이미 인덱스 내에서 정렬되어 있기 때문이다. 예를 들면 쿼리에서 BETWEEN, <, >, GROUP BY, ORDER BY, 그리고 MAX, MIN, COUNT와 같은 집합 함수를 사용하는 경우가 여기에 해당된다.
클러스터드 인덱스는 유일한 값을 가지고 레코드를 검색하는 쿼리를 사용하거나(예를 들면 직원 번호) 레코드의 거의 모든 데이터를 가져오고자 할 때 효과적이다. 왜냐하면 이 쿼리는 인덱스만으로 처리가 가능하기 때문이다.
클러스터드 인덱스는 국가 또는 주(state) 데이터와 같이 유일한 값이 제한적인 컬럼을 액세스 하는 쿼리에 효과적이다. 그러나 컬럼의 데이터가 예/아니오, 남성/여성 처럼 매우 적은 유일한 값을 갖고 있으면 이 컬럼에는 인덱스를 걸지 않는 것이 좋다.
클러스터드 인덱스는 JOIN 또는 GROUP BY 절을 사용하는 쿼리에 효과적이다.
클러스터드 인덱스는 매우 많은 레코드를 반환하는 쿼리를 사용할 때 효과적이다. 왜냐하면 데이터가 인덱스에 모두 들어 있으므로 다른 곳에서 찾아올 필요가 없기 때문이다.
테이블에 INSERT 작업이 많다면 아이디, 날짜 등과 같이 증가하는 컬럼에는 클러스터드 인덱스를 만들지 않아야 한다.왜냐하면 클러스터드 인덱스는 데이터를 물리적으로 정렬되도록 유지하기 때문에 증가하는 컬럼에 생성된 클러스터드 인덱스는 새로운 데이터를 테이블의 동일한 페이지에 삽입하여 테이블이 과도하게 사용됨으로써 I/O 병목현상을 유발할 수 있다. 이 때에는 클러스터드 인덱스로 사용할 다른 컬럼을 찾아보는 것이 좋다.

한 가지 난처한 문제는 클러스터드 인덱스를 만들 필요가 있는 컬럼이 하나 이상인 경우가 있다는 것이다. 그러나 하나의 테이블에는 오직 하나의 클러스터드 인덱스만을 생성할 수 있기 때문에 모든 가능성을 평가한 다음에 가장 효과적일 것으로 판단되는 하나만을 선택해야 한다.


넌클러스터드 인덱스를 선택하는 방법

넌클러스터드 인덱스는 테이블에 원하는 만큼 생성할 수 있기 때문에 클러스터드 인덱스를 선택하는 것보다 비교적 쉽다. 다음은 넌클러스터드 인덱스를 생성할 컬럼을 선택하는 방법이다.
넌클러스터드 인덱스는 반환되는 레코드의 개수가 적은 쿼리(하나의 레코드 포함)와 인덱스의 선택도가 높은 경우에(95% 이상) 사용하면 좋다.
컬럼의 데이터가 95% 이상의 유일한 값을 갖지 않는다면 SQL Server 쿼리 옵티마이저는 해당 컬럼에 생성되어 있는 넌클러스터드 인덱스를 사용하지 않을 가능성이 높다. 따라서 적어도 95% 이상 유일한 값을 갖지 않는 컬럼에는 넌클러스터드 인덱스를 만들지 않는 것이 좋다. 예를 들어 “예”, “아니오”를 데이터로 갖는 컬럼은 95% 이상 유일해야 한다는 조건에 부합되지 않는다.
인덱스의 폭(width)을 가능한 좁게 유지한다. 특히 복합(다중 컬럼) 인덱스를 만들 때는 더욱 그러하다. 이렇게 하면 인덱스의 크기가 감소하기 때문에 인덱스를 읽을 때 필요한 읽기 횟수도 줄어들므로 성능 향상을 얻을 수 있다.
가능하다면 문자보다는 정수 값을 가진 컬럼에 인덱스를 만들어야 한다. 정수 값은 문자보다 처리하는데 필요한 오버헤드가 작다.
응용프로그램이 같은 테이블에 대해서 동일한 쿼리를 반복해서 실행한다면 해당 테이블에 커버링 인덱스를 만들어 보도록 한다. 커버링 인덱스는 쿼리에서 사용하는 모든 컬럼을 포괄하는 인덱스이다. 인덱스에 찾고자 하는 데이터가 모두 들어 있기 때문에 SQL Server는 데이터를 찾기 위해서 테이블을 참조할 필요가 없으며 결과적으로 논리적 및 물리적 I/O가 감소하는 장점이 있다. 그러나 인덱스가 과도하게 커지면(컬럼이 너무 많아서) I/O가 증가하여 성능이 떨어질 수도 있다.
인덱스는 쿼리의 WHERE 절이 인덱스의 가장 왼쪽의 컬럼과 일치할 때에만 사용된다. 따라서 “City, State”와 같은 복합 인덱스를 만들었다면 WHERE City=’Houston’과 같은 쿼리는 인덱스를 사용하겠지만 WHERE STATE=’TX’는 인덱스를 사용하지 않는다.

일반적으로 테이블에 하나의 인덱스만 필요하다면 클러스터드 인덱스로 만드는 것이 좋다. 그러나 테이블에 하나 이상의 인덱스가 필요한 경우에는 넌클러스터드 인덱스를 만들 수 밖에 없다. 위의 내용을 충실하게 따른다면 최적의 인덱스를 선택할 수 있을 것이다.


### sequence 현재 번호를 수정하고, ssdt 게시를 해도 초기화 되지 않도록 처리.
출처 : https://gokhanatil.com/2011/01/how-to-set-current-value-of-a-sequence-without-droppingrecreating.html
```
ALTER SEQUENCE [dbo].[SeqUserUid01] INCREMENT BY 200000;
DECLARE @uid BIGINT = NEXT VALUE FOR [SeqUserUid01]
select @uid as 'user uid'
set @uid = NEXT VALUE FOR [SeqUserUid01]
select @uid as 'user uid'
ALTER SEQUENCE [dbo].[SeqUserUid01] INCREMENT BY 1;

```

## page lookup이 높게 나올 때 실행계획이 올바른지 확인하는 방법

```
select object_name(object_id), *
from sys.dm_exec_procedure_stats
where database_id = db_id()
order by total_logical_reads desc
```

