#!/bin/bash

# Ubuntu wxWidgets 字体显示问题修复脚本
# 专门解决Ubuntu下GUI应用程序中文字体不显示的问题

echo "🔍 开始诊断Ubuntu字体显示问题..."

# 检查系统信息
echo "📋 系统信息："
echo "  操作系统: $(lsb_release -d | cut -f2)"
echo "  架构: $(uname -m)"
echo "  桌面环境: $XDG_CURRENT_DESKTOP"

# 检查字体包安装状态
echo ""
echo "🔤 检查中文字体包安装状态："
font_packages=("fonts-wqy-microhei" "fonts-noto-cjk" "fonts-dejavu" "fonts-liberation")

for package in "${font_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package"; then
        echo "  ✅ $package - 已安装"
    else
        echo "  ❌ $package - 未安装"
    fi
done

# 检查可用字体
echo ""
echo "🔍 检查系统中可用的中文字体："
echo "  文泉驿微米黑:"
fc-list | grep -i "wenquanyi" | head -3 || echo "    未找到"

echo "  Noto字体:"
fc-list | grep -i "noto.*cjk" | head -3 || echo "    未找到"

echo "  DejaVu字体:"
fc-list | grep -i "dejavu" | head -3 || echo "    未找到"

# 检查字体缓存
echo ""
echo "🔄 检查字体缓存："
if [ -d "/var/cache/fontconfig" ]; then
    echo "  ✅ 字体缓存目录存在"
    echo "  缓存文件数量: $(find /var/cache/fontconfig -name "*.cache" | wc -l)"
else
    echo "  ❌ 字体缓存目录不存在"
fi

# 检查wxWidgets安装
echo ""
echo "📦 检查wxWidgets安装："
if pkg-config --exists wx-config; then
    echo "  ✅ wxWidgets已安装"
    echo "  版本: $(pkg-config --modversion wx-config 2>/dev/null || echo '未知')"
else
    echo "  ❌ wxWidgets未安装或配置不正确"
fi

# 检查环境变量
echo ""
echo "🌍 检查环境变量："
echo "  LANG: ${LANG:-未设置}"
echo "  LC_ALL: ${LC_ALL:-未设置}"
echo "  FONTCONFIG_PATH: ${FONTCONFIG_PATH:-未设置}"

# 提供修复建议
echo ""
echo "🔧 修复建议："

# 安装缺失的字体包
missing_fonts=()
for package in "${font_packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package"; then
        missing_fonts+=("$package")
    fi
done

if [ ${#missing_fonts[@]} -gt 0 ]; then
    echo "1️⃣ 安装缺失的字体包："
    echo "   sudo apt-get update"
    echo "   sudo apt-get install -y ${missing_fonts[*]}"
fi

# 刷新字体缓存
echo ""
echo "2️⃣ 刷新字体缓存："
echo "   sudo fc-cache -fv"

# 设置环境变量
echo ""
echo "3️⃣ 设置环境变量（临时）："
echo "   export LANG=zh_CN.UTF-8"
echo "   export LC_ALL=zh_CN.UTF-8"

# 重新编译程序
echo ""
echo "4️⃣ 重新编译程序："
echo "   ./build_linux.sh"

# 运行程序
echo ""
echo "5️⃣ 运行程序："
echo "   ./build/bin/wxmusicplayer"

# 如果字体包缺失，自动安装
if [ ${#missing_fonts[@]} -gt 0 ]; then
    echo ""
    echo "🚀 自动安装缺失的字体包..."
    sudo apt-get update
    sudo apt-get install -y "${missing_fonts[@]}"
    
    echo "🔄 刷新字体缓存..."
    sudo fc-cache -fv
    
    echo "✅ 字体包安装完成！"
fi

echo ""
echo "📝 如果问题仍然存在，请尝试以下额外步骤："
echo "1. 重启系统"
echo "2. 检查是否有其他字体冲突"
echo "3. 尝试使用不同的桌面环境"
echo "4. 检查wxWidgets编译选项"

echo ""
echo "🎯 诊断完成！"
