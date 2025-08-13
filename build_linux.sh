#!/bin/bash

# wxWidgets 音乐播放器 Linux 构建脚本
# 使用 vcpkg 管理依赖

set -e  # 遇到错误时退出

echo "🎵 开始构建 wxWidgets 音乐播放器..."

# 检查并安装系统依赖
echo "🔧 检查系统依赖..."
if command -v apt-get &> /dev/null; then
    echo "📦 安装 Ubuntu/Debian 依赖..."
    sudo apt-get update
    sudo apt-get install -y cmake build-essential pkg-config
    sudo apt-get install -y libgtk-3-dev
    sudo apt-get install -y libltdl-dev autoconf automake libtool
elif command -v yum &> /dev/null; then
    echo "📦 安装 CentOS/RHEL 依赖..."
    sudo yum install -y cmake gcc-c++ pkg-config
    sudo yum install -y gtk3-devel
    sudo yum install -y libtool autoconf automake
else
    echo "⚠️  未知的包管理器，请手动安装依赖"
fi

# 检查是否已安装 vcpkg
if [ ! -d "vcpkg" ]; then
    echo "📦 安装 vcpkg..."
    git clone https://github.com/Microsoft/vcpkg.git
    cd vcpkg
    ./bootstrap-vcpkg.sh
    cd ..
else
    echo "✅ vcpkg 已存在"
fi

# 安装依赖
echo "📥 安装依赖包..."
cd vcpkg
./vcpkg install wxwidgets:x64-linux-dynamic
./vcpkg install sdl2:x64-linux-dynamic
./vcpkg install sdl2-mixer:x64-linux-dynamic
echo "✅ 依赖安装完成"
echo "📁 vcpkg安装目录: $(pwd)/installed"
ls -la installed/x64-linux-dynamic/
cd ..

# 创建构建目录
echo "🔨 创建构建目录..."
rm -rf build
mkdir build
cd build

# 配置项目
echo "⚙️  配置项目..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_TOOLCHAIN_FILE=../vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-linux-dynamic

# 编译项目
echo "🔨 编译项目..."
make -j$(nproc)

echo "✅ 构建完成！"
echo "🎵 可执行文件位置: build/bin/wxmusicplayer"

# 测试运行
if [ -f "bin/wxmusicplayer" ]; then
    echo "🧪 测试运行应用程序..."
    ./bin/wxmusicplayer --help || echo "应用程序启动成功！"
else
    echo "❌ 构建失败，未找到可执行文件"
    exit 1
fi
