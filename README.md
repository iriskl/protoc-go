# protoc-go

一个 Protocol Buffers 编译工具，专为 Go 项目设计，支持自动检测项目结构和智能文件编译。

## ✨ 功能特性

- 🔍 **智能项目检测** - 自动识别 proto 目录和项目结构
- 📁 **多种编译模式** - 支持编译所有文件或指定特定文件
- 🛤️ **灵活路径支持** - 支持绝对路径、相对路径、文件名等多种输入方式
- 🚀 **一键生成** - 自动生成 Go、gRPC 和 gRPC-Gateway 代码
- 📂 **子目录支持** - 完美处理复杂的 proto 目录结构
- 🎨 **友好输出** - 彩色输出和清晰的错误提示
- 🌍 **通用性强** - 适用于任何 Go + protobuf 项目

## 📋 前置要求

### 1. 安装 protoc

**Windows:**

```bash
# 使用 Chocolatey
choco install protoc

# 使用 Scoop
scoop install protobuf

# 或手动下载：https://github.com/protocolbuffers/protobuf/releases
```

**macOS:**

```bash
brew install protobuf
```

**Linux:**

```bash
# Ubuntu/Debian
sudo apt install protobuf-compiler

# CentOS/RHEL
sudo yum install protobuf-compiler
```

### 2. 安装 Go 插件

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
```

### 3. 验证安装

```powershell
protoc --version
protoc-gen-go --version
```

## 🚀 快速开始

### 方法一：一键使用（推荐）

```powershell
# 下载并立即使用
iex (iwr -UseBasicParsing "https://raw.githubusercontent.com/iriskl/protoc-go/main/Microsoft.PowerShell_profile.ps1").Content

# 现在就可以使用 cproto 命令了！
cproto
```

### 方法二：下载后使用

```powershell
# 下载脚本文件
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iriskl/protoc-go/main/Microsoft.PowerShell_profile.ps1" -OutFile "protoc-go.ps1"

# 导入函数到当前会话
. .\protoc-go.ps1

# 开始使用
cproto
```

### 方法三：永久安装到 PowerShell 配置

```powershell
# 备份现有配置（如果存在）
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

# 下载并添加到 PowerShell 配置文件
$scriptContent = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iriskl/protoc-go/main/Microsoft.PowerShell_profile.ps1" -UseBasicParsing
$scriptContent.Content | Add-Content -Path $PROFILE

# 重新加载配置
. $PROFILE

# 现在每次打开 PowerShell 都可以使用 cproto 命令
```

## 📖 使用指南

### 基本语法

```powershell
cproto [files...]
```

### 使用示例

#### 编译所有 proto 文件

```powershell
# 编译当前项目中的所有 proto 文件
cproto
```

#### 编译指定文件

```powershell
# 编译单个文件
cproto user.proto

# 自动添加 .proto 扩展名
cproto user

# 编译多个文件
cproto user.proto order.proto

# 混合使用
cproto user order.proto
```

#### 路径支持

```powershell
# 使用相对路径
cproto proto/user.proto
cproto ./api/v1/user.proto

# 使用绝对路径
cproto "C:\Projects\MyApp\proto\user.proto"

# 在 proto 子目录中直接编译
cd proto/api/v1
cproto user.proto
```

### 支持的项目结构

✅ **简单项目结构**

```
project/
├── proto/
│   ├── user.proto
│   └── order.proto
└── main.go
```

✅ **复杂项目结构**

```
project/
├── api/
│   └── proto/
│       ├── user/
│       │   ├── user.proto
│       │   └── profile.proto
│       └── order/
│           └── order.proto
└── cmd/
    └── server/
        └── main.go
```

✅ **微服务项目结构**

```
microservices/
├── user-service/
│   └── proto/
│       └── user.proto
├── order-service/
│   └── proto/
│       └── order.proto
└── shared/
    └── proto/
        └── common.proto
```

### 使用场景

#### 场景 1：在项目根目录

```powershell
PS C:\MyProject> cproto
Compiling 3 proto file(s)...
  user.proto -> C:\MyProject\proto
  order.proto -> C:\MyProject\proto
  common.proto -> C:\MyProject\proto
  [OK] user.proto
  [OK] order.proto
  [OK] common.proto
Compilation completed!
```

#### 场景 2：在 proto 目录中

```powershell
PS C:\MyProject\proto> cproto user
Compiling 1 proto file(s)...
  user.proto -> C:\MyProject\proto
  [OK] user.proto
Compilation completed!
```

#### 场景 3：编译特定文件

```powershell
PS C:\MyProject> cproto proto/api/user.proto
Compiling 1 proto file(s)...
  user.proto -> C:\MyProject\proto\api
  [OK] user.proto
Compilation completed!
```

## 🔧 高级功能

### 自动依赖解析

脚本会自动处理 proto 文件之间的导入依赖关系：

```protobuf
// user.proto
syntax = "proto3";
import "common/types.proto";  // 自动解析导入
```

### 智能错误处理

```powershell
PS > cproto nonexistent.proto
Warning: File not found: nonexistent.proto
No valid proto files found!
```

### 详细的编译输出

成功时显示简洁信息，失败时显示详细的调试信息：

```powershell
PS > cproto broken.proto
Compiling 1 proto file(s)...
  broken.proto -> C:\Project\proto
  [FAIL] broken.proto (Exit code: 1)
    Command: protoc --proto_path=proto --go_out=proto ...
Compilation completed!
```

## 🚨 故障排除

### 常见问题及解决方案

#### 1. "protoc: command not found"

```powershell
# 检查 protoc 是否已安装
protoc --version

# 如果未安装，请按照前置要求部分重新安装
```

#### 2. "protoc-gen-go: program not found"

```powershell
# 重新安装 Go 插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# 确保 $GOPATH/bin 在 PATH 中
echo $env:PATH
```

#### 3. "No proto directory found"

```powershell
# 确保在正确的目录中运行
# 以下任一目录都可以：
cd your-project          # 项目根目录（包含 proto/ 子目录）
cd your-project/proto     # proto 目录本身
cd your-project/proto/api # proto 的任何子目录
```

#### 4. 导入路径错误

确保您的 proto 文件中的导入路径相对于 proto 根目录：

```protobuf
// ✅ 正确
import "api/user.proto";

// ❌ 错误
import "../api/user.proto";
```

### 调试技巧

#### 检查环境

```powershell
# 检查所有相关工具
protoc --version
where.exe protoc-gen-go
where.exe protoc-gen-go-grpc
where.exe protoc-gen-grpc-gateway

# 检查 Go 环境
go env GOPATH
go env GOBIN
```

#### 手动测试

```powershell
# 手动运行 protoc 命令进行调试
protoc --proto_path=proto --go_out=proto --go_opt=paths=source_relative proto/user.proto
```

## 💡 最佳实践

### 1. 项目结构建议

```
your-project/
├── proto/              # 所有 .proto 文件的根目录
│   ├── api/
│   │   └── v1/
│   │       ├── user.proto
│   │       └── order.proto
│   └── common/
│       └── types.proto
├── pkg/               # 生成的 Go 代码
└── cmd/
    └── server/
        └── main.go
```

### 2. Proto 文件组织

- 使用有意义的目录结构
- 保持导入路径清晰简洁
- 为不同的服务创建独立的目录



## ⭐ 支持

如果这个工具对您有帮助，请给个 Star ⭐！

