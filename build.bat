@echo off
echo 正在构建 wxWidgets 音乐播放器...

REM 检查是否存在build目录，如果不存在则创建
if not exist "build" mkdir build

REM 进入build目录
cd build

REM 配置项目
echo 正在配置项目...
cmake .. -G "Visual Studio 16 2019" -A x64

REM 检查cmake是否成功
if %ERRORLEVEL% NEQ 0 (
    echo CMake配置失败！
    echo 请确保已安装以下依赖：
    echo - CMake 3.16+
    echo - Visual Studio 2019+ 或 MinGW-w64
    echo - wxWidgets 3.1.0+
    pause
    exit /b 1
)

REM 编译项目
echo 正在编译项目...
cmake --build . --config Release

REM 检查编译是否成功
if %ERRORLEVEL% NEQ 0 (
    echo 编译失败！
    pause
    exit /b 1
)

echo.
echo 编译成功！
echo 可执行文件位置: build\Release\wxmusicplayer.exe
echo.
echo 按任意键运行程序...
pause

REM 运行程序
start Release\wxmusicplayer.exe

cd ..
