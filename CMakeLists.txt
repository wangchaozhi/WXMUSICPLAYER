cmake_minimum_required(VERSION 3.16)
project(wxmusicplayer VERSION 1.0.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 查找wxWidgets
find_package(wxWidgets CONFIG REQUIRED)

# 查找音频库
find_package(PkgConfig REQUIRED)
pkg_check_modules(SDL2 REQUIRED sdl2)
pkg_check_modules(SDL2_MIXER REQUIRED SDL2_mixer)

# 源文件列表
set(SOURCES
    src/SimpleMusicPlayer.cpp
)

# 创建可执行文件
add_executable(wxmusicplayer ${SOURCES})

# 设置包含目录
target_include_directories(wxmusicplayer PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${SDL2_INCLUDE_DIRS}
    ${SDL2_MIXER_INCLUDE_DIRS}
)

# 链接wxWidgets库和音频库
target_link_libraries(wxmusicplayer PRIVATE 
    wx::core 
    wx::base
    ${SDL2_LIBRARIES}
    ${SDL2_MIXER_LIBRARIES}
)

# 平台特定设置
if(WIN32)
    # 注释掉动态链接定义，使用静态链接
    # target_compile_definitions(wxmusicplayer PRIVATE WXUSINGDLL)
    
    # 设置Windows子系统
    set_target_properties(wxmusicplayer PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    
    # 添加Windows资源文件（如果有的话）
    # target_sources(wxmusicplayer PRIVATE resources.rc)
    
elseif(APPLE)
    # macOS特定设置
    set_target_properties(wxmusicplayer PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )
    
elseif(UNIX)
    # Linux特定设置
    target_compile_definitions(wxmusicplayer PRIVATE __UNIX__)
endif()

# 编译选项
if(MSVC)
    target_compile_options(wxmusicplayer PRIVATE /W4)
elseif(WIN32)
    # Windows MinGW使用GBK编码
    target_compile_options(wxmusicplayer PRIVATE -Wall -Wextra -Wpedantic -fexec-charset=GBK)
else()
    # Linux/macOS使用UTF-8编码
    target_compile_options(wxmusicplayer PRIVATE -Wall -Wextra -Wpedantic)
endif()

# 安装规则
install(TARGETS wxmusicplayer
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)

# 复制资源文件到输出目录
file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin)

# 显示配置信息
message(STATUS "wxWidgets version: ${wxWidgets_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")
