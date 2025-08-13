# wxWidgets DLL问题修复脚本 (PowerShell版本)
Write-Host "========================================" -ForegroundColor Green
Write-Host "   wxWidgets DLL问题修复脚本" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 检查是否在正确的目录
if (-not (Test-Path "CMakeLists.txt")) {
    Write-Host "错误：请在项目根目录运行此脚本" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

Write-Host "正在检查wxWidgets安装..." -ForegroundColor Yellow

# 检查常见的wxWidgets安装路径
$wxWidgetsPath = $null

# 检查vcpkg安装
if ($env:VCPKG_ROOT -and (Test-Path "$env:VCPKG_ROOT\installed\x64-windows\bin\wxmsw31u_core_vc14x_x64.dll")) {
    Write-Host "找到vcpkg安装的wxWidgets" -ForegroundColor Green
    $wxWidgetsPath = "$env:VCPKG_ROOT\installed\x64-windows\bin"
}

# 检查标准安装路径
elseif (Test-Path "C:\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll") {
    Write-Host "找到标准安装的wxWidgets" -ForegroundColor Green
    $wxWidgetsPath = "C:\wxWidgets-3.1.0\lib\vc14x_dll"
}

elseif (Test-Path "C:\wxWidgets-3.2.0\lib\vc14x_dll\wxmsw32u_core_vc14x_x64.dll") {
    Write-Host "找到标准安装的wxWidgets 3.2.0" -ForegroundColor Green
    $wxWidgetsPath = "C:\wxWidgets-3.2.0\lib\vc14x_dll"
}

# 检查Program Files
elseif (Test-Path "$env:ProgramFiles\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll") {
    Write-Host "找到Program Files中的wxWidgets" -ForegroundColor Green
    $wxWidgetsPath = "$env:ProgramFiles\wxWidgets-3.1.0\lib\vc14x_dll"
}

elseif (Test-Path "$env:ProgramFiles(x86)\wxWidgets-3.1.0\lib\vc14x_dll\wxmsw31u_core_vc14x_x64.dll") {
    Write-Host "找到Program Files (x86)中的wxWidgets" -ForegroundColor Green
    $wxWidgetsPath = "$env:ProgramFiles(x86)\wxWidgets-3.1.0\lib\vc14x_dll"
}

if ($wxWidgetsPath) {
    Write-Host ""
    Write-Host "找到wxWidgets路径: $wxWidgetsPath" -ForegroundColor Green
    Write-Host "正在复制DLL文件到输出目录..." -ForegroundColor Yellow
    
    # 创建输出目录
    $outputDir = "build\bin\Release"
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # 复制DLL文件
    Write-Host "复制核心DLL文件..." -ForegroundColor Yellow
    $dllFiles = @(
        "wxmsw31u_core_vc14x_x64.dll",
        "wxbase31u_vc14x_x64.dll", 
        "wxbase31u_net_vc14x_x64.dll",
        "wxbase31u_xml_vc14x_x64.dll"
    )
    
    foreach ($dll in $dllFiles) {
        $sourcePath = Join-Path $wxWidgetsPath $dll
        $destPath = Join-Path $outputDir $dll
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $destPath -Force
            Write-Host "已复制: $dll" -ForegroundColor Green
        } else {
            Write-Host "未找到: $dll" -ForegroundColor Yellow
        }
    }
    
    # 检查是否复制成功
    if (Test-Path "$outputDir\wxmsw31u_core_vc14x_x64.dll") {
        Write-Host ""
        Write-Host "DLL文件复制成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "现在可以运行程序了：" -ForegroundColor Green
        Write-Host "$outputDir\wxmusicplayer.exe" -ForegroundColor Cyan
        Write-Host ""
        
        $runChoice = Read-Host "是否立即运行程序？(Y/N)"
        if ($runChoice -eq "Y" -or $runChoice -eq "y") {
            Start-Process "$outputDir\wxmusicplayer.exe"
        }
    } else {
        Write-Host "DLL文件复制失败！" -ForegroundColor Red
        Write-Host "请检查路径和权限" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "未找到wxWidgets DLL文件！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请选择安装方式：" -ForegroundColor Yellow
    Write-Host "1. 使用vcpkg安装（推荐）" -ForegroundColor Cyan
    Write-Host "2. 手动下载安装" -ForegroundColor Cyan
    Write-Host "3. 使用静态链接重新编译" -ForegroundColor Cyan
    Write-Host ""
    
    $choice = Read-Host "请选择 (1-3)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "使用vcpkg安装wxWidgets..." -ForegroundColor Yellow
            Write-Host "请运行以下命令：" -ForegroundColor Cyan
            Write-Host "vcpkg install wxwidgets:x64-windows" -ForegroundColor Green
            Write-Host ""
            Write-Host "安装完成后重新运行此脚本" -ForegroundColor Yellow
        }
        "2" {
            Write-Host ""
            Write-Host "请访问 https://www.wxwidgets.org/downloads/" -ForegroundColor Cyan
            Write-Host "下载并安装wxWidgets，然后重新运行此脚本" -ForegroundColor Yellow
        }
        "3" {
            Write-Host ""
            Write-Host "将重新编译为静态链接版本..." -ForegroundColor Yellow
            Write-Host "请运行 build_static.bat 脚本" -ForegroundColor Green
        }
        default {
            Write-Host "无效选择" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "修复完成！" -ForegroundColor Green
Read-Host "按任意键退出"
