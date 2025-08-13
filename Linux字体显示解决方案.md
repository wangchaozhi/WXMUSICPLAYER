# Linux下wxWidgets GUI字体显示问题解决方案

## 🚀 Ubuntu快速解决方案

如果您的Ubuntu系统下GUI文字不显示，请按以下步骤操作：

### 步骤1：运行诊断脚本
```bash
chmod +x fix_ubuntu_fonts.sh
./fix_ubuntu_fonts.sh
```

### 步骤2：安装字体包
```bash
sudo apt-get update
sudo apt-get install -y fonts-wqy-microhei fonts-noto-cjk fonts-dejavu fonts-liberation
sudo fc-cache -fv
```

### 步骤3：设置环境变量
```bash
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
```

### 步骤4：重新编译并运行
```bash
./build_linux.sh
./build/bin/wxmusicplayer
```

### 步骤5：如果仍有问题，运行字体测试
```bash
chmod +x build_font_test.sh
./build_font_test.sh
./font_test
```

---

## 问题描述

在Ubuntu/Linux系统下运行wxWidgets应用程序时，GUI界面中的中文字符可能显示为空白或方块，这是因为：

1. **字体名称不兼容**：Windows字体名称在Linux上不存在
2. **字符编码问题**：Linux使用UTF-8，而Windows使用GBK
3. **缺少中文字体**：系统可能没有安装中文字体包

## 解决方案

### 方案1：安装中文字体包（推荐）

在Ubuntu/Debian系统上安装中文字体：

```bash
# 安装文泉驿微米黑字体（推荐）
sudo apt-get update
sudo apt-get install -y fonts-wqy-microhei

# 安装Noto字体（Google开源字体）
sudo apt-get install -y fonts-noto-cjk

# 安装其他中文字体
sudo apt-get install -y fonts-dejavu fonts-liberation
```

### 方案2：代码层面的字体设置

已修改 `src/SimpleMusicPlayer.cpp` 中的字体设置：

```cpp
// 设置支持中文的字体（跨平台兼容）
wxFont font;
#ifdef __WXMSW__
    // Windows系统使用微软雅黑
    font = wxFont(9, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, false, wxT("Microsoft YaHei"));
#else
    // Linux/macOS系统使用系统默认中文字体
    font = wxFont(9, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, false, wxT(""));
    // 尝试设置常见的中文字体
    if (!font.SetFaceName(wxT("WenQuanYi Micro Hei")) &&
        !font.SetFaceName(wxT("Noto Sans CJK SC")) &&
        !font.SetFaceName(wxT("DejaVu Sans")) &&
        !font.SetFaceName(wxT("Liberation Sans"))) {
        // 如果都失败，使用系统默认字体
        font = wxFont(9, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL);
    }
#endif
SetFont(font);
```

### 方案3：环境变量设置

在运行程序前设置字体环境变量：

```bash
# 设置字体路径
export FONTCONFIG_PATH=/etc/fonts
export FC_CACHE_DIR=/var/cache/fontconfig

# 刷新字体缓存
fc-cache -fv

# 运行程序
./wxmusicplayer
```

### 方案4：系统字体配置

创建或修改字体配置文件：

```bash
# 创建字体配置文件
sudo mkdir -p /etc/fonts/conf.d
sudo nano /etc/fonts/conf.d/99-chinese-fonts.conf
```

添加以下内容：

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="pattern">
        <test qual="any" name="family">
            <string>sans</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
            <string>WenQuanYi Micro Hei</string>
            <string>Noto Sans CJK SC</string>
            <string>DejaVu Sans</string>
            <string>Liberation Sans</string>
        </edit>
    </match>
</fontconfig>
```

## 常见Linux中文字体

| 字体名称 | 包名 | 安装命令 |
|---------|------|----------|
| WenQuanYi Micro Hei | fonts-wqy-microhei | `sudo apt install fonts-wqy-microhei` |
| Noto Sans CJK SC | fonts-noto-cjk | `sudo apt install fonts-noto-cjk` |
| DejaVu Sans | fonts-dejavu | `sudo apt install fonts-dejavu` |
| Liberation Sans | fonts-liberation | `sudo apt install fonts-liberation` |

## 测试方法

1. **检查字体是否安装**：
   ```bash
   fc-list | grep -i "wenquanyi\|noto\|dejavu"
   ```

2. **检查字体缓存**：
   ```bash
   fc-cache -v
   ```

3. **运行程序测试**：
   ```bash
   ./build/bin/wxmusicplayer
   ```

## 故障排除

### 问题1：字体仍然显示为方块
**解决方案**：
- 确保安装了中文字体包
- 重启应用程序
- 检查字体缓存：`fc-cache -fv`

### 问题2：部分文字显示正常，部分不正常
**解决方案**：
- 检查源代码文件编码是否为UTF-8
- 确保所有中文字符串都使用了正确的编码

### 问题3：字体显示太小或太大
**解决方案**：
- 调整字体大小：修改代码中的字体大小参数
- 使用系统字体设置工具调整DPI

## 推荐的完整解决流程

1. **安装字体包**：
   ```bash
   sudo apt-get install -y fonts-wqy-microhei fonts-noto-cjk
   ```

2. **刷新字体缓存**：
   ```bash
   fc-cache -fv
   ```

3. **重新编译程序**：
   ```bash
   ./build_linux.sh
   ```

4. **运行测试**：
   ```bash
   ./build/bin/wxmusicplayer
   ```

## 总结

Linux下wxWidgets字体显示问题主要是由于字体名称不兼容和缺少中文字体包导致的。通过安装合适的中文字体包和修改代码中的字体设置，可以完美解决这个问题。
