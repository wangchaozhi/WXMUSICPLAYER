@echo off
echo ========================================
echo    wxWidgets 音乐播放器 - 运行脚本
echo ========================================
echo.

REM 检查可执行文件是否存在
if not exist "build\bin\wxmusicplayer.exe" (
    echo 错误：未找到可执行文件
    echo 请先运行 build_simple.bat 编译项目
    pause
    exit /b 1
)

echo 正在复制DLL文件...

REM 复制wxWidgets DLL文件
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\wxbase32u_gcc_custom.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\wxmsw32u_core_gcc_custom.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\wxbase32u_net_gcc_custom.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\wxbase32u_xml_gcc_custom.dll" "build\bin\" >nul 2>nul

REM 复制依赖的DLL文件
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libpng16.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libjpeg-62.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libzlib1.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libexpat-1.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libpcre2-8.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libpcre2-16.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libpcre2-32.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libpcre2-posix.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libtiff.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\libturbojpeg.dll" "build\bin\" >nul 2>nul
copy "E:\dev\vcpkg\installed\x64-mingw-dynamic\bin\liblzma.dll" "build\bin\" >nul 2>nul

echo DLL文件复制完成！
echo.
echo 正在启动音乐播放器...
echo.

REM 运行程序
cd build\bin
start wxmusicplayer.exe

cd ..\..

echo.
echo 程序已启动！
echo 如果程序没有显示窗口，请检查任务管理器中的进程
pause
