#!/bin/bash

# AppImage构建调试脚本
echo "🔍 AppImage构建调试脚本"
echo "========================"

# 检查系统信息
echo "📋 系统信息："
echo "Ubuntu版本: $(lsb_release -d | cut -f2)"
echo "内核版本: $(uname -r)"
echo "架构: $(uname -m)"

# 检查FUSE
echo ""
echo "🔧 FUSE检查："
if command -v fusermount &> /dev/null; then
    echo "✅ fusermount 已安装"
else
    echo "❌ fusermount 未安装"
fi

if lsmod | grep -q fuse; then
    echo "✅ FUSE模块已加载"
else
    echo "❌ FUSE模块未加载"
fi

# 检查AppImage工具
echo ""
echo "📦 AppImage工具检查："
if command -v appimagetool &> /dev/null; then
    echo "✅ appimagetool 已安装"
    appimagetool --version || echo "无法获取版本信息"
else
    echo "❌ appimagetool 未安装"
fi

# 检查AppDir结构
echo ""
echo "📁 AppDir结构检查："
if [ -d "AppDir" ]; then
    echo "AppDir目录存在"
    echo "可执行文件："
    find AppDir -type f -executable
    echo ""
    echo "库文件："
    find AppDir -name "*.so*" | head -10
else
    echo "❌ AppDir目录不存在"
fi

# 检查依赖
echo ""
echo "🔗 依赖检查："
if [ -f "AppDir/usr/bin/wxmusicplayer" ]; then
    echo "检查可执行文件依赖："
    ldd AppDir/usr/bin/wxmusicplayer
else
    echo "❌ 可执行文件不存在"
fi

echo ""
echo "🎯 建议："
echo "1. 如果FUSE有问题，尝试：sudo modprobe fuse"
echo "2. 如果权限有问题，尝试：sudo chmod +x appimagetool"
echo "3. 如果依赖有问题，检查库文件是否完整"
echo "4. 如果仍然失败，使用tar.gz包作为替代"
