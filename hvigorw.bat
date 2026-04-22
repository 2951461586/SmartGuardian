@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "DEVECO_NODE=F:\IDE\DevEco Studio\tools\node\node.exe"
set "WRAPPER_JS=F:\IDE\DevEco Studio\tools\hvigor\bin\hvigorw.js"
set "DEVECO_SDK_ROOT=F:\IDE\DevEco Studio\sdk"

if not defined DEVECO_SDK_HOME set "DEVECO_SDK_HOME=%DEVECO_SDK_ROOT%"
if not defined HOS_SDK_HOME set "HOS_SDK_HOME=%DEVECO_SDK_ROOT%"
if not defined OHOS_BASE_SDK_HOME set "OHOS_BASE_SDK_HOME=%DEVECO_SDK_ROOT%"

if not exist "%WRAPPER_JS%" (
  echo ERROR: Hvigor wrapper not found at "%WRAPPER_JS%".
  exit /b 1
)

if exist "%DEVECO_NODE%" (
  "%DEVECO_NODE%" "%WRAPPER_JS%" %*
) else (
  node "%WRAPPER_JS%" %*
)

exit /b %ERRORLEVEL%
