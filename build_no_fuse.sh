#!/bin/bash

# 无FUSE构建脚本 - 直接创建tar.gz包
echo "🎵 wxWidgets 音乐播放器 - 无FUSE构建脚本"
echo "=========================================="

set -e  # 遇到错误时退出

# 检查并安装系统依赖
echo "🔧 检查系统依赖..."
if command -v apt-get &> /dev/null; then
    echo "📦 安装 Ubuntu/Debian 依赖..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq cmake build-essential pkg-config
    sudo apt-get install -y -qq libgtk-3-dev
    sudo apt-get install -y -qq libsdl2-dev libsdl2-mixer-dev
    sudo apt-get install -y -qq libwxgtk3.0-gtk3-dev || sudo apt-get install -y -qq libwxgtk3.0-dev || sudo apt-get install -y -qq wx3.0-headers
elif command -v yum &> /dev/null; then
    echo "📦 安装 CentOS/RHEL 依赖..."
    sudo yum install -y cmake gcc-c++ pkg-config
    sudo yum install -y gtk3-devel
    sudo yum install -y wxGTK3-devel SDL2-devel SDL2_mixer-devel
else
    echo "⚠️  未知的包管理器，请手动安装依赖"
fi

# 创建构建目录
echo "🔨 创建构建目录..."
rm -rf build
mkdir build
cd build

# 配置项目
echo "⚙️  配置项目..."
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

# 编译项目
echo "🔨 编译项目..."
make -j$(nproc)

echo "✅ 构建完成！"

# 创建包目录结构
echo "📦 创建包结构..."
mkdir -p package/usr/bin
mkdir -p package/usr/lib
mkdir -p package/usr/share/applications
mkdir -p package/usr/share/icons/hicolor/256x256/apps

# 复制可执行文件
cp bin/wxmusicplayer package/usr/bin/
chmod +x package/usr/bin/wxmusicplayer

# 复制依赖库
echo "📋 复制依赖库..."
ldd bin/wxmusicplayer | grep -v linux-vdso | grep -v ld-linux | awk '{print $3}' | while read lib; do
    if [ -n "$lib" ] && [ -f "$lib" ]; then
        # 跳过系统核心库
        libname=$(basename "$lib")
        if [[ "$libname" =~ ^(libc\.|libm\.|libgcc_s\.|libstdc\+\+\.|ld-linux|libpthread\.|libdl\.|libutil\.|libgomp\.|libatomic\.|libquadmath\.|libgfortran\.|libgcc_s_|libstdc\+\+_|libmvec\.) ]]; then
            echo "跳过系统库: $lib"
            continue
        fi
        echo "复制: $lib"
        cp "$lib" package/usr/lib/ 2>/dev/null || echo "复制失败: $lib"
    fi
done

# 复制wxWidgets库
echo "复制wxWidgets库..."
find /usr/lib -name "libwx_gtk3u_*.so*" -exec cp {} package/usr/lib/ \; 2>/dev/null || true
find /usr/lib/x86_64-linux-gnu -name "libwx_gtk3u_*.so*" -exec cp {} package/usr/lib/ \; 2>/dev/null || true

# 创建桌面文件
cat > package/usr/share/applications/wxmusicplayer.desktop << EOF
[Desktop Entry]
Name=wxMusicPlayer
GenericName=Music Player
Comment=Simple music player built with wxWidgets
Exec=wxmusicplayer
Icon=wxmusicplayer
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Player;
Keywords=music;player;audio;wxwidgets;
EOF

# 创建图标
convert -size 256x256 xc:transparent -fill "#4A90E2" -draw "circle 128,128 128,64" \
        -fill white -pointsize 60 -gravity center -annotate +0+0 "🎵" \
        package/usr/share/icons/hicolor/256x256/apps/wxmusicplayer.png

# 创建运行脚本
cat > package/run_linux.sh << 'EOF'
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
EOF

chmod +x package/run_linux.sh

# 创建tar.gz包
echo "📦 创建tar.gz包..."
cd ..
tar -czf wxMusicPlayer-Linux-x86_64.tar.gz -C build/package .

echo "✅ 包创建完成！"
echo "📁 包位置: $(pwd)/wxMusicPlayer-Linux-x86_64.tar.gz"
echo ""
echo "📝 使用说明："
echo "1. 解压包: tar -xzf wxMusicPlayer-Linux-x86_64.tar.gz"
echo "2. 进入目录: cd wxMusicPlayer-Linux-x86_64"
echo "3. 运行程序: ./run_linux.sh"
