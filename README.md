# wxWidgets 音乐播放器

一个基于wxWidgets框架开发的简单音乐播放器，支持播放WAV和MP3格式的音频文件。

## 功能特性

- 🎵 支持播放WAV和MP3格式音频文件
- 📋 播放列表管理（添加、删除、选择）
- ⏯️ 播放控制（播放、暂停、停止）
- 🎨 简洁直观的用户界面
- 🌏 完整的中文界面支持

## 系统要求

- Windows 10/11
- MinGW-w64 或 Visual Studio 2019+
- CMake 3.16+
- wxWidgets 3.1.0+

## 安装依赖

### 使用vcpkg安装wxWidgets（推荐）

```bash
# 安装vcpkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat

# 安装wxWidgets
.\vcpkg install wxwidgets:x64-mingw-dynamic
```

### 手动安装wxWidgets

1. 访问 [wxWidgets官网](https://www.wxwidgets.org/downloads/)
2. 下载并安装wxWidgets
3. 编译wxWidgets库

## 编译项目

### 方法1：使用构建脚本（推荐）

```bash
# 设置环境变量
$env:CMAKE_PREFIX_PATH = "E:\dev\vcpkg\installed\x64-mingw-dynamic"

# 运行构建脚本
.\build_simple.bat
```

### 方法2：手动编译

```bash
# 创建构建目录
mkdir build
cd build

# 配置项目
cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release

# 编译项目
cmake --build . --config Release
```

## 运行程序

编译完成后，运行以下命令启动程序：

```bash
# 复制DLL文件并运行
.\run_with_dlls.bat
```

或者直接运行：

```bash
.\build\bin\wxmusicplayer.exe
```

## 项目结构

```
wxmusicplayer/
├── src/                    # 源代码目录
│   └── SimpleMusicPlayer.cpp
├── include/                # 头文件目录
├── assets/                 # 资源文件目录
├── build/                  # 构建输出目录
├── CMakeLists.txt          # CMake配置文件
├── build_simple.bat        # 构建脚本
├── run_with_dlls.bat       # 运行脚本
└── README.md              # 项目说明文档
```

## 中文显示解决方案

本项目使用 `-fexec-charset=GBK` 编译器选项解决中文显示问题：

- 源代码保持UTF-8编码
- 编译时自动转换为GBK编码
- 无需使用wxT()宏或复杂的本地化设置

## 技术栈

- **GUI框架**: wxWidgets 3.2.6
- **构建系统**: CMake
- **编译器**: MinGW-w64
- **语言**: C++17
- **音频支持**: wxSound

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交Issue和Pull Request！

## 作者

[wangchaozhi](https://github.com/wangchaozhi)

## 更新日志

### v1.0.0
- 初始版本发布
- 基本播放功能
- 播放列表管理
- 中文界面支持
