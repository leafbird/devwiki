## Batch File

### 폴더 내 파일 순회 예제 : unify.bat

```
@echo off
del /q unify.sql
for /r %%f in (*.sql) do (
  type %%f >> unify.sql
)
pause
```


### 특정 폴더 하위에서 일정 기간 지난 파일을 삭제하기 : DeleteExpiredFiles.bat

```
@echo off
SET DELETE_PATH=%1
SET EXPIRED_PERIOD_BY_DAY=%2

IF NOT EXIST %DELETE_PATH% (
    goto usage
)

IF %EXPIRED_PERIOD_BY_DAY% == "" (
    goto usage
)


forfiles /P "%DELETE_PATH%" /S /D -%EXPIRED_PERIOD_BY_DAY% -c "cmd /c if @isdir==FALSE (del /s/q/f @path) else (rmdir /s/q @path)"

goto end

:usage
@ECHO Error in script usage. The correct usage is:
@ECHO     %0 "{Path} {Expired Period}"
@ECHO:
@ECHO example:
@ECHO     %0 "d:\HIT\Korea\" 90
goto end

:end
ENDLOCAL

```

### 배치파일을 작업 스케줄러에 등록하기 : RegisterDailySchedule.bat

```
@echo off
SETLOCAL

SET START_TIME=%1
SET SCHEDULING_FILE=%~dpnx2

IF "%SCHEDULING_FILE%"=="" (
    goto usage
)

IF NOT EXIST %SCHEDULING_FILE% (
    goto usage
)

IF "%START_TIME%" == "" (
    goto usage
)

FOR %%i IN (%SCHEDULING_FILE%) DO (
SET FILE_NAME=%%~ni
)

schtasks.exe /Create /TN %FILE_NAME% /SC DAILY /ST %START_TIME% /TR "%SCHEDULING_FILE%" /RU %userdomain%\%username% /RL HIGHEST /NP
goto end

:usage
@ECHO Error in script usage. The correct usage is:
@ECHO     %0 " {StartTime HH:mm format} {ScriptFile}"
@ECHO:
@ECHO example:
@ECHO     %0 03:00 "DeleteSymbolFile.bat"
goto end

:end
ENDLOCAL

```

### 작업 스케줄러에서 특정 작업 삭제하기 : DeleteDailySchedule.bat

```
@echo off
SET DELETE_PATH=%1
SET EXPIRED_PERIOD_BY_DAY=%2

IF NOT EXIST %DELETE_PATH% (
    goto usage
)

IF %EXPIRED_PERIOD_BY_DAY% == "" (
    goto usage
)


forfiles /P "%DELETE_PATH%" /S /D -%EXPIRED_PERIOD_BY_DAY% -c "cmd /c if @isdir==FALSE (del /s/q/f @path) else (rmdir /s/q @path)"

goto end

:usage
@ECHO Error in script usage. The correct usage is:
@ECHO     %0 "{Path} {Expired Period}"
@ECHO:
@ECHO example:
@ECHO     %0 "d:\HIT\Korea\" 90
goto end

:end
ENDLOCAL
```
