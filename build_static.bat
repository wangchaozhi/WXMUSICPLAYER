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

echo 正在创建静态链接版本的CMakeLists.txt...

REM 创建静态链接版本的CMakeLists.txt
(
echo cmake_minimum_required(VERSION 3.16^)
echo project(wxmusicplayer VERSION 1.0.0 LANGUAGES CXX^)
echo.
echo # 设置C++标准
echo set(CMAKE_CXX_STANDARD 17^)
echo set(CMAKE_CXX_STANDARD_REQUIRED ON^)
echo.
echo # 设置输出目录
echo set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin^)
echo set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib^)
echo set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib^)
echo.
echo # 查找wxWidgets
echo find_package(wxWidgets CONFIG REQUIRED^)
echo.
echo # 源文件列表
echo set(SOURCES
echo     src/SimpleMusicPlayer.cpp
echo ^)
echo.
echo # 创建可执行文件
echo add_executable(wxmusicplayer ${SOURCES}^)
echo.
echo # 设置包含目录
echo target_include_directories(wxmusicplayer PRIVATE 
echo     ${CMAKE_CURRENT_SOURCE_DIR}/include
echo     ${CMAKE_CURRENT_SOURCE_DIR}/src
echo ^)
echo.
echo # 链接wxWidgets库（静态链接）
echo target_link_libraries(wxmusicplayer PRIVATE wx::core wx::base^)
echo.
echo # 平台特定设置
echo if(WIN32^)
echo     # 静态链接，不需要WXUSINGDLL
echo     set_target_properties(wxmusicplayer PROPERTIES
echo         WIN32_EXECUTABLE TRUE
echo     ^)
echo endif(^)
echo.
echo # 复制资源文件到输出目录
echo file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin^)
) > CMakeLists_static.txt

echo 静态链接配置文件已创建：CMakeLists_static.txt
echo.

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
echo 构建类型: 静态链接
echo.

REM 删除旧的构建目录
if exist "build" (
    echo 删除旧的构建目录...
    rmdir /s /q "build"
)

REM 创建构建目录
mkdir build
cd build

REM 配置项目（使用静态链接配置）
echo 正在配置项目（静态链接）...
cmake .. -G %GENERATOR% -A x64 -DCMAKE_TOOLCHAIN_FILE=..\CMakeLists_static.txt
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
echo 正在编译项目（静态链接）...
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
echo 静态链接编译成功！
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
