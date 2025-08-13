@echo off
echo ========================================
echo    wxWidgets DLL问题修复脚本
echo ========================================
echo.

REM 检查是否在正确的目录
if not exist "CMakeLists.txt" (
    echo 错误：请在项目根目录运行此脚本
    pause
    exit /b 1
)

echo 正在检查wxWidgets安装...

REM 检查常见的wxWidgets安装路径
set WXWIDGETS_FOUND=0

REM 检查vcpkg安装
if exist "%VCPKG_ROOT%\installed\x64-windows\bin\wxmsw31u_core_vc14x_x64.dll" (
    echo 找到vcpkg安装的wxWidgets
    set WXWIDGETS_PATH=%VCPKG_ROOT%\installed\x64-windows\bin
    set WXWIDGETS_FOUND=1
    goto :copy_dlls
)

REM 检查标准安装路径
if exist "C:\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll" (
    echo 找到标准安装的wxWidgets
    set WXWIDGETS_PATH=C:\wxWidgets-3.1.0\lib\vc14x_dll
    set WXWIDGETS_FOUND=1
    goto :copy_dlls
)

if exist "C:\wxWidgets-3.2.0\lib\vc14x_dll\wxmsw32u_core_vc14x_x64.dll" (
    echo 找到标准安装的wxWidgets 3.2.0
    set WXWIDGETS_PATH=C:\wxWidgets-3.2.0\lib\vc14x_dll
    set WXWIDGETS_FOUND=1
    goto :copy_dlls
)

REM 检查Program Files
if exist "%ProgramFiles%\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll" (
    echo 找到Program Files中的wxWidgets
    set WXWIDGETS_PATH=%ProgramFiles%\wxWidgets-3.1.0\lib\vc14x_dll
    set WXWIDGETS_FOUND=1
    goto :copy_dlls
)

if exist "%ProgramFiles(x86)%\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll" (
    echo 找到Program Files (x86)中的wxWidgets
    set WXWIDGETS_PATH=%ProgramFiles(x86)%\wxWidgets-3.1.0\lib\vc14x_dll
    set WXWIDGETS_FOUND=1
    goto :copy_dlls
)

echo.
echo 未找到wxWidgets DLL文件！
echo.
echo 请选择安装方式：
echo 1. 使用vcpkg安装（推荐）
echo 2. 手动下载安装
echo 3. 使用静态链接重新编译
echo.
set /p choice="请选择 (1-3): "

if "%choice%"=="1" (
    echo.
    echo 使用vcpkg安装wxWidgets...
    echo 请运行以下命令：
    echo vcpkg install wxwidgets:x64-windows
    echo.
    echo 安装完成后重新运行此脚本
    pause
    exit /b 1
) else if "%choice%"=="2" (
    echo.
    echo 请访问 https://www.wxwidgets.org/downloads/
    echo 下载并安装wxWidgets，然后重新运行此脚本
    pause
    exit /b 1
) else if "%choice%"=="3" (
    echo.
    echo 将重新编译为静态链接版本...
    goto :static_build
) else (
    echo 无效选择
    pause
    exit /b 1
)

:copy_dlls
echo.
echo 找到wxWidgets路径: %WXWIDGETS_PATH%
echo 正在复制DLL文件到输出目录...

REM 创建输出目录
if not exist "build\bin\Release" mkdir "build\bin\Release"

REM 复制DLL文件
echo 复制核心DLL文件...
copy "%WXWIDGETS_PATH%\wxmsw31u_core_vc14x_x64.dll" "build\bin\Release\" >nul 2>nul
copy "%WXWIDGETS_PATH%\wxbase31u_vc14x_x64.dll" "build\bin\Release\" >nul 2>nul
copy "%WXWIDGETS_PATH%\wxbase31u_net_vc14x_x64.dll" "build\bin\Release\" >nul 2>nul
copy "%WXWIDGETS_PATH%\wxbase31u_xml_vc14x_x64.dll" "build\bin\Release\" >nul 2>nul

REM 检查是否复制成功
if exist "build\bin\Release\wxmsw31u_core_vc14x_x64.dll" (
    echo DLL文件复制成功！
    echo.
    echo 现在可以运行程序了：
    echo build\bin\Release\wxmusicplayer.exe
    echo.
    echo 是否立即运行程序？(Y/N)
    set /p run_choice=
    if /i "%run_choice%"=="Y" (
        start "build\bin\Release\wxmusicplayer.exe"
    )
) else (
    echo DLL文件复制失败！
    echo 请检查路径和权限
)

goto :end

:static_build
echo.
echo 正在创建静态链接版本的CMakeLists.txt...

REM 备份原文件
copy "CMakeLists.txt" "CMakeLists.txt.backup" >nul 2>nul

REM 创建静态链接版本
echo cmake_minimum_required(VERSION 3.16) > "CMakeLists_static.txt"
echo project(wxmusicplayer VERSION 1.0.0 LANGUAGES CXX) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 设置C++标准 >> "CMakeLists_static.txt"
echo set(CMAKE_CXX_STANDARD 17) >> "CMakeLists_static.txt"
echo set(CMAKE_CXX_STANDARD_REQUIRED ON) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 设置输出目录 >> "CMakeLists_static.txt"
echo set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin) >> "CMakeLists_static.txt"
echo set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib) >> "CMakeLists_static.txt"
echo set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 查找wxWidgets >> "CMakeLists_static.txt"
echo find_package(wxWidgets CONFIG REQUIRED) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 源文件列表 >> "CMakeLists_static.txt"
echo set(SOURCES >> "CMakeLists_static.txt"
echo     src/SimpleMusicPlayer.cpp >> "CMakeLists_static.txt"
echo ) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 创建可执行文件 >> "CMakeLists_static.txt"
echo add_executable(wxmusicplayer ${SOURCES}) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 设置包含目录 >> "CMakeLists_static.txt"
echo target_include_directories(wxmusicplayer PRIVATE >> "CMakeLists_static.txt"
echo     ${CMAKE_CURRENT_SOURCE_DIR}/include >> "CMakeLists_static.txt"
echo     ${CMAKE_CURRENT_SOURCE_DIR}/src >> "CMakeLists_static.txt"
echo ) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 链接wxWidgets库（静态链接） >> "CMakeLists_static.txt"
echo target_link_libraries(wxmusicplayer PRIVATE wx::core wx::base) >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 平台特定设置 >> "CMakeLists_static.txt"
echo if(WIN32) >> "CMakeLists_static.txt"
echo     # 静态链接，不需要WXUSINGDLL >> "CMakeLists_static.txt"
echo     set_target_properties(wxmusicplayer PROPERTIES >> "CMakeLists_static.txt"
echo         WIN32_EXECUTABLE TRUE >> "CMakeLists_static.txt"
echo     ) >> "CMakeLists_static.txt"
echo endif() >> "CMakeLists_static.txt"
echo. >> "CMakeLists_static.txt"
echo # 复制资源文件到输出目录 >> "CMakeLists_static.txt"
echo file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin) >> "CMakeLists_static.txt"

echo 静态链接版本已创建：CMakeLists_static.txt
echo.
echo 请运行以下命令重新编译：
echo 1. 删除build目录
echo 2. 运行: cmake -S . -B build -f CMakeLists_static.txt
echo 3. 运行: cmake --build build --config Release
echo.
echo 静态链接版本不需要额外的DLL文件！

:end
echo.
echo 修复完成！
pause
