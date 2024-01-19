## bitset

```
#include <string>
#include <bitset>
using namespace std;

// bitset 선언
bitset< 8 > bit;
//bit	[8](0,0,0,0,0,0,0,0)	std::bitset<8>


// 전체 비트 세트
bit.set();
//bit	[8](1,1,1,1,1,1,1,1)	std::bitset<8>


// 전체 비트 리셋
bit.reset();
//bit	[8](0,0,0,0,0,0,0,0)	std::bitset<8>


// 할당 된 비트 수
int bitsize = (int)bit.size();
//bitsize	8


// 세트 된 비트 존재 여부 감사
bool bAny = bit.any();
//bAny	false	bool
bool bNone = bit.none();
//bNone	true	bool


// 첫 번째, 세 번째 비트 할당
bit.set( 0, true );
//bit	[8](1,0,0,0,0,0,0,0)	std::bitset<8>
bit.set( 2, true );
//bit	[8](1,0,1,0,0,0,0,0)	std::bitset<8>


// 다섯 번째 비트 반전
bit.flip( 4 );
//bit	[8](1,0,1,0,1,0,0,0)	std::bitset<8>


// 모든 비트 반전
bit.flip();
//bit	[8](0,1,0,1,0,1,1,1)	std::bitset<8>


// 네 번째 비트 감사
bool bFlag = bit.test( 3 );
//bFlag	true	bool


// 여섯 번째 비트 감사
bFlag = bit[ 5 ];
//bFlag	true	bool


// 세트 된 비트 존재 여부 감사
bAny = bit.any();
//bAny	true	bool
bNone = bit.none();
//bNone	false	bool


// 세트 된 비트 수
int setcount = (int)bit.count();
//setcount	5	int


// 값 할당
bit = 0x01;
//bit	[8](1,0,0,0,0,0,0,0)	std::bitset<8>
bit = 0xF0;
//bit	[8](0,0,0,0,1,1,1,1)	std::bitset<8>


// 문자로 변환
string strBits = bit.to_string();
//strBits	"11110000"


// 숫자로 변환
int    nBitVal = bit.to_ulong();
//nBitVal	240
```