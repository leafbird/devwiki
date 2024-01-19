## 윈도우 path가 디렉토리인지 확인하기


```
attrib = GetFileAttributes(path);

if ( attrib == 0xFFFFFFFF || !(attrib & FILE_ATTRIBUTE_DIRECTORY) ){
    /* not a valid directory */
}
```

## 실행 파일 생성 시각 얻기.

```
inline std::wstring GetTimeStampByNameW()
{
	std::wstring strReturn;

	// 실행 파일 생성 시각 얻기.
	HANDLE hFile;
	HANDLE hFMap;
	wchar_t szFileName[MAX_PATH];
	DWORD dwSize = MAX_PATH;
	::QueryFullProcessImageName( ::GetCurrentProcess(), 0, szFileName, &dwSize);
	hFile = CreateFileW( szFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
	
	if( hFile == INVALID_HANDLE_VALUE )
	{
		return strReturn;
	}
	
	// 파일 맵핑 오브젝트를 만든다.
	hFMap = CreateFileMappingW( hFile, NULL, PAGE_READONLY, 0, 0, NULL );
	// 주소 공간에 맵한다.
	HMODULE hModule;
	hModule = ( HMODULE )MapViewOfFile( hFMap, FILE_MAP_READ, 0, 0, 0 );
	CTime time( GetTimestampForLoadedLibrary( hModule ) );
	
	strReturn = (CStringW)time.Format( _T("%Y-%m-%d %H:%M:%S") );
	
	UnmapViewOfFile( hModule );
	CloseHandle( hFMap );
	CloseHandle( hFile );
	
	return strReturn;
}
```