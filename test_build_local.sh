#!/bin/bash

# 本地构建测试脚本
echo "🧪 本地构建测试脚本"
echo "===================="

# 检查系统
echo "📋 系统信息："
echo "操作系统: $(uname -s)"
echo "架构: $(uname -m)"
echo "内核版本: $(uname -r)"

# 检查依赖
echo ""
echo "🔍 检查依赖："
deps=("cmake" "g++" "pkg-config" "make")
for dep in "${deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "✅ $dep 已安装"
    else
        echo "❌ $dep 未安装"
    fi
done

# 检查wxWidgets
echo ""
echo "🎨 检查wxWidgets："
if pkg-config --exists wx-config; then
    echo "✅ wxWidgets 已安装"
    wx-config --version
else
    echo "❌ wxWidgets 未安装"
    echo "请安装: sudo apt-get install libwxgtk3.2-dev"
fi

# 尝试构建
echo ""
echo "🔨 尝试构建："
if [ -f "CMakeLists.txt" ]; then
    echo "✅ 找到CMakeLists.txt"
    
    # 清理旧的构建目录
    rm -rf build
    mkdir build
    cd build
    
    # 配置
    echo "⚙️  配置项目..."
    if cmake .. -DCMAKE_BUILD_TYPE=Release; then
        echo "✅ 配置成功"
        
        # 编译
        echo "🔨 编译项目..."
        if make -j$(nproc); then
            echo "✅ 编译成功"
            
            # 检查可执行文件
            if [ -f "bin/wxmusicplayer" ]; then
                echo "✅ 可执行文件创建成功"
                echo "文件信息:"
                file bin/wxmusicplayer
                echo "依赖库:"
                ldd bin/wxmusicplayer | head -10
            else
                echo "❌ 可执行文件未找到"
            fi
        else
            echo "❌ 编译失败"
        fi
    else
        echo "❌ 配置失败"
    fi
    
    cd ..
else
    echo "❌ 未找到CMakeLists.txt"
fi

echo ""
echo "🎯 测试完成！"
