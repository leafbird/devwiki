## Large Address Aware

빌드된 실행파일을 수정하여 /lws 플래그를 심는 방법.

    editbin /LARGEADDRESSAWARE "C:\Python26\ArcGIS10.0\python.exe"

빌드된 실행파일에 /lws가 설정 되어 있는지 확인하는 방법.

    dumpbin /headers "C:\Python26\ArcGIS10.0\python.exe" | more
    You should see "...Application can handle large (>2GB) addresses..."