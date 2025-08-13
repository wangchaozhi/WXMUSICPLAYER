@echo off
echo ========================================
echo    wxWidgets 音乐播放器 - 静态链接构建
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

echo 正在使用静态链接配置构建项目...
echo.

REM 删除旧的构建目录
if exist "build" (
    echo 删除旧的构建目录...
    rmdir /s /q "build"
)

REM 创建构建目录
mkdir build
cd build

REM 配置项目
echo 正在配置项目...
cmake .. -G "MinGW Makefiles"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo CMake配置失败！
    echo 请确保已安装wxWidgets
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
echo 注意：静态链接版本不需要额外的DLL文件！
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
