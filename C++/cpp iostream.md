## cpp/iostream

### ostream_iterator

```
    std::vector<int> vec( 10, 0 ); // 0이 10개 들어있는 벡터.
    std::copy( begin(vec), end(vec), std::ostream_iterator<int>( std::cout, ", " ) );

    // 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, - 끝에도 ,가 찍힌다.
```

### floating-point

출력 포멧
10진수
std::dec

16진수
std::hex

8진수
std::oct

'\n'을 삽입하고 스트림 내용 삭제
std::endl

문자열에 '\0' 널문자 삽입
ends

c로 채우기 문자 설정
setfill(int c)

n으로 필드의 폭 설정
std::setw(int n)

n으로 부동 소수점의 유효자리 설정
std::setprecision(int n)

형식플래그 설정
std::setiosflags(long f)

형식플래그 삭제
std::resetiosflags(long f)



형식플래그값
setw() 폭안에 출력을 좌측으로 정렬
ios::left

setw() 폭안에 출력을 우측으로 정렬
ios::right

부동 소수점표기, 지수형태로
ios::scientific

부동 소수점표기, 소수형태로
ios::fixed

10진수로 수치 표기
ios::dec

16진수로 수치 표기
ios::hex

8진수로 수치 표기
ios::oct

16진수와 과학용 표기의 문자를 대문자 형식으로 표기
ios::uppercase

수치 베이스 접두 문자를 출력
ios::showbase

양수를 출력할 때 + 부호를 출력
ios::showpos

정확도를 위해 필요하면 끝의 0들을 출력
ios::showpoint