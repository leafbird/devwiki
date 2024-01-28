## zlib

### minizip

zip파일을 다룰 수 있는 라이브러리.

출처 : http://stackoverflow.com/questions/11370908/how-do-i-use-minizip-on-zlib

```
int CreateZipFile (std::vector<wstring> paths)
{
    zipFile zf = zipOpen(std::string(destinationPath.begin(), destinationPath.end()).c_str(), APPEND_STATUS_CREATE);
    if (zf == NULL)
        return 1;

    bool _return = true;
    for (size_t i = 0; i < paths.size(); i++)
    {
        std::fstream file(paths[i].c_str(), std::ios::binary | std::ios::in);
        if (file.is_open())
        {
            file.seekg(0, std::ios::end);
            long size = file.tellg();
            file.seekg(0, std::ios::beg);
    
            std::vector<char> buffer(size);
            if (size == 0 || file.read(&buffer[0], size))
            {
                zip_fileinfo zfi = { 0 };
                std::wstring fileName = paths[i].substr(paths[i].rfind('\\')+1);
    
                if (S_OK == zipOpenNewFileInZip(zf, std::string(fileName.begin(), fileName.end()).c_str(), &zfi, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION))
                {
                    if (zipWriteInFileInZip(zf, size == 0 ? "" : &buffer[0], size))
                        _return = false;
    
                    if (zipCloseFileInZip(zf))
                        _return = false;
    
                    file.close();
                    continue;
                }
            }
            file.close();
        }
        _return = false;
    }
   `
    if (zipClose(zf, NULL))
        return 3;
    
    if (!_return)
        return 4;
    return S_OK;
}
```