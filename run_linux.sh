#!/bin/bash

# wxWidgets 音乐播放器 Linux 运行脚本
echo "🎵 wxWidgets 音乐播放器 Linux 运行脚本"
echo "========================================"

# 检查是否在正确的目录
if [ ! -f "usr/bin/wxmusicplayer" ]; then
    echo "❌ 错误：请在解压后的目录中运行此脚本"
    echo "   例如：tar -xzf wxMusicPlayer-Linux-x86_64.tar.gz"
    echo "        cd wxMusicPlayer-Linux-x86_64"
    echo "        ./run_linux.sh"
    exit 1
fi

# 设置库路径
export LD_LIBRARY_PATH="$(pwd)/usr/lib:$LD_LIBRARY_PATH"

echo "📁 当前目录: $(pwd)"
echo "🔧 库路径: $LD_LIBRARY_PATH"

# 检查可执行文件
if [ ! -x "usr/bin/wxmusicplayer" ]; then
    echo "❌ 错误：可执行文件不存在或没有执行权限"
    exit 1
fi

# 检查依赖库
echo "📋 检查依赖库..."
ldd usr/bin/wxmusicplayer

# 运行程序
echo "🚀 启动音乐播放器..."
./usr/bin/wxmusicplayer "$@"
