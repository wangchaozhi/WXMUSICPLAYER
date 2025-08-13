@echo off
echo ========================================
echo    wxWidgets 音乐播放器构建脚本
echo ========================================
echo.

REM 检查CMake是否安装
where cmake >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 错误：未找到CMake，请先安装CMake
    echo 下载地址：https://cmake.org/download/
    pause
    exit /b 1
)

REM 检查编译器
echo 检测可用的编译器...

REM 检查Visual Studio
where cl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo 找到Visual Studio编译器
    set GENERATOR="Visual Studio 16 2019"
    set COMPILER=MSVC
    goto :build
)

REM 检查MinGW
where g++ >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo 找到MinGW编译器
    set GENERATOR="MinGW Makefiles"
    set COMPILER=MinGW
    goto :build
)

echo 错误：未找到支持的编译器
echo 请安装以下之一：
echo - Visual Studio 2019+
echo - MinGW-w64
pause
exit /b 1

:build
echo.
echo 使用编译器: %COMPILER%
echo 生成器: %GENERATOR%
echo.

REM 创建构建目录
if not exist "build" mkdir build
cd build

REM 配置项目
echo 正在配置项目...
cmake .. -G %GENERATOR% -A x64
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo CMake配置失败！
    echo 可能的原因：
    echo 1. wxWidgets未安装或未正确配置
    echo 2. 编译器版本不兼容
    echo 3. CMake版本过低
    echo.
    echo 解决方案：
    echo 1. 安装wxWidgets：https://www.wxwidgets.org/downloads/
    echo 2. 使用vcpkg安装：vcpkg install wxwidgets:x64-windows
    echo 3. 更新CMake到3.16+
    pause
    exit /b 1
)

REM 编译项目
echo.
echo 正在编译项目...
cmake --build . --config Release
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 编译失败！
    echo 请检查错误信息并修复问题。
    pause
    exit /b 1
)

echo.
echo ========================================
echo 编译成功！
echo ========================================
echo.
echo 可执行文件位置: build\bin\Release\wxmusicplayer.exe
echo.

REM 检查可执行文件是否存在
if exist "bin\Release\wxmusicplayer.exe" (
    echo 是否立即运行程序？(Y/N)
    set /p choice=
    if /i "%choice%"=="Y" (
        echo 启动音乐播放器...
        start bin\Release\wxmusicplayer.exe
    )
) else (
    echo 警告：未找到可执行文件
    echo 请检查编译输出目录
)

cd ..
echo.
echo 构建完成！
pause
