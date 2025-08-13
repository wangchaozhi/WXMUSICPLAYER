#!/bin/bash

# 编译字体测试程序

echo "🔨 编译字体测试程序..."

# 检查wxWidgets
if ! pkg-config --exists wx-config; then
    echo "❌ wxWidgets未安装，请先安装wxWidgets"
    exit 1
fi

# 编译测试程序
g++ -o font_test test_fonts.cpp $(wx-config --cxxflags --libs) -std=c++17

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    echo "🎯 运行测试程序："
    echo "   ./font_test"
else
    echo "❌ 编译失败！"
    exit 1
fi
