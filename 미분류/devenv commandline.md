## devenv commandline

### command line에서 솔루션을 빌드하고 싶을 때

 call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" amd64

 devenv 솔루션파일 /build "Release|x64"


### 전처리 과정이 끝난 cpp 파일을 확인하고 싶을 때 : /E

 * /E 전처리 마친 파일을 보여줌.
 * /I 인클루드 경로 추가설정.

	cl /I "C:\Dev\Some\Path" /I "C:\other\Path" /E source.cpp > temp.cpp
