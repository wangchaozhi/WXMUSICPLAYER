@echo off
echo ========================================
echo    复制所有DLL文件到程序目录
echo ========================================
echo.

REM 检查可执行文件是否存在
if not exist "build\bin\wxmusicplayer.exe" (
    echo 错误：未找到可执行文件
    echo 请先编译项目
    pause
    exit /b 1
)

echo 正在复制所有DLL文件...

REM 复制所有wxWidgets相关的DLL文件
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\wx*.dll" "build\bin\" >nul 2>nul

REM 复制所有依赖的DLL文件
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\lib*.dll" "build\bin\" >nul 2>nul

echo 所有DLL文件复制完成！
echo.
echo 现在可以运行程序了：
echo build\bin\wxmusicplayer.exe
echo.
pause
