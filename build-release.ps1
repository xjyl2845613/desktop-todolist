# 一键打包脚本
Write-Host "开始打包 Desktop Todo List 项目..."

# 检查是否安装了npm
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到 npm，请确保已安装 Node.js" -ForegroundColor Red
    exit 1
}

# 安装依赖
Write-Host "安装依赖..." -ForegroundColor Green
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 依赖安装失败" -ForegroundColor Red
    exit 1
}

# 执行打包
Write-Host "执行打包..." -ForegroundColor Green
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 打包失败" -ForegroundColor Red
    exit 1
}

# 查找生成的可执行文件
$portableExe = "dist\DesktopTodoList.exe"

if (-not (Test-Path $portableExe)) {
    Write-Host "错误: 未找到生成的可执行文件" -ForegroundColor Red
    exit 1
}

# 创建输出目录
$outputDir = "release"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# 创建zip压缩包
$zipFile = "$outputDir\DesktopTodoList-$(Get-Date -Format 'yyyyMMdd').zip"
Write-Host "创建压缩包: $zipFile" -ForegroundColor Green

# 复制可执行文件到临时目录
$tempDir = "temp-release"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir | Out-Null
}
New-Item -ItemType Directory -Path $tempDir | Out-Null
Copy-Item $portableExe $tempDir | Out-Null

# 创建README文件
$readmeContent = @"
# Desktop Todo List - 桌面待办清单

## 功能特点
- 桌面悬浮待办清单
- 支持工作和个人任务分类
- 历史记录查询和导出
- 开机自启设置

## 使用方法
1. 解压本压缩包
2. 双击 DesktopTodoList.exe 运行
3. 点击右下角的悬浮图标打开待办清单

## 注意事项
- 数据存储在用户数据目录中，确保有读写权限
- 支持 Windows 10 及以上系统
"@

$readmeContent | Out-File -FilePath "$tempDir\README.txt" -Encoding UTF8

# 压缩文件
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFile)

# 清理临时目录
Remove-Item -Recurse -Force $tempDir | Out-Null

Write-Host "打包完成! 压缩包已生成: $zipFile" -ForegroundColor Green
Write-Host "解压后即可使用，无需安装环境。" -ForegroundColor Cyan
