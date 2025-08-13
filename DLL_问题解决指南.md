# wxWidgets 音乐播放器 - DLL问题解决指南

## 问题描述

在Windows系统上运行wxWidgets应用程序时，可能会遇到以下错误：
- `无法启动此程序，因为计算机中丢失 wxmsw31u_core_vc14x_x64.dll`
- `无法启动此程序，因为计算机中丢失 wxbase31u_vc14x_x64.dll`
- 其他类似的DLL缺失错误

## 解决方案

### 方案1：使用修复脚本（推荐）

1. 运行 `fix_dll_issues.bat` 脚本
2. 脚本会自动检测wxWidgets安装位置
3. 自动复制所需的DLL文件到程序目录
4. 如果未找到wxWidgets，会提供安装指导

### 方案2：静态链接编译（最佳方案）

1. 运行 `build_static.bat` 脚本
2. 这会创建一个静态链接版本的程序
3. 静态链接版本不需要额外的DLL文件
4. 程序体积会稍大，但部署更简单

### 方案3：手动安装wxWidgets

#### 使用vcpkg（推荐）

```bash
# 安装vcpkg（如果还没有）
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat

# 安装wxWidgets
.\vcpkg install wxwidgets:x64-windows

# 集成到Visual Studio（可选）
.\vcpkg integrate install
```

#### 手动下载安装

1. 访问 https://www.wxwidgets.org/downloads/
2. 下载Windows版本的wxWidgets
3. 解压到 `C:\wxWidgets-3.1.0\` 目录
4. 编译wxWidgets库（参考官方文档）

### 方案4：手动复制DLL文件

如果已经安装了wxWidgets，可以手动复制DLL文件：

1. 找到wxWidgets安装目录（通常在 `C:\wxWidgets-3.1.0\lib\vc14x_dll\`）
2. 复制以下文件到程序目录：
   - `wxmsw31u_core_vc14x_x64.dll`
   - `wxbase31u_vc14x_x64.dll`
   - `wxbase31u_net_vc14x_x64.dll`
   - `wxbase31u_xml_vc14x_x64.dll`

## 常见问题

### Q: 为什么会出现DLL缺失问题？
A: wxWidgets默认使用动态链接库（DLL），程序运行时需要这些DLL文件。如果系统中没有安装wxWidgets或DLL文件不在PATH中，就会出现此问题。

### Q: 静态链接和动态链接有什么区别？
A: 
- **动态链接**：程序体积小，但需要DLL文件
- **静态链接**：程序体积大，但不需要额外的DLL文件

### Q: 如何检查wxWidgets是否正确安装？
A: 运行以下命令检查：
```bash
# 检查CMake是否能找到wxWidgets
cmake --find-package -DNAME=wxWidgets -DCOMPILER_ID=MSVC

# 检查vcpkg安装
vcpkg list | findstr wxwidgets
```

### Q: 编译时出现链接错误怎么办？
A: 
1. 确保wxWidgets库已正确编译
2. 检查CMakeLists.txt中的链接设置
3. 尝试使用静态链接版本

## 推荐的解决步骤

1. **首先尝试**：运行 `fix_dll_issues.bat`
2. **如果失败**：运行 `build_static.bat` 创建静态链接版本
3. **长期方案**：使用vcpkg安装wxWidgets

## 文件说明

- `fix_dll_issues.bat` - DLL问题自动修复脚本
- `build_static.bat` - 静态链接构建脚本
- `build.bat` - 原始动态链接构建脚本
- `build_simple.bat` - 简化版构建脚本

## 技术支持

如果问题仍然存在，请：
1. 检查错误信息的具体内容
2. 确认wxWidgets版本和编译器版本匹配
3. 查看CMake配置输出信息
