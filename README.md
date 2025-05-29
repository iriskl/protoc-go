# cproto - 通用 Protocol Buffer 编译工具

## 概述
`cproto` 是一个强大而灵活的 PowerShell 函数，用于编译 Protocol Buffer 文件。它支持 Go、gRPC 和 grpc-gateway 代码生成，并且能够智能地处理各种项目结构和使用场景。

## 功能特点

### ✨ 智能目录检测
- 自动检测当前是否在 proto 目录或其子目录中
- 自动检测项目根目录下是否有 proto 子目录
- 支持复杂的嵌套 proto 目录结构

### 📁 多种文件指定方式
- **绝对路径**: `cproto "C:\path\to\file.proto"`
- **相对路径**: `cproto "proto/book/book.proto"`
- **文件名**: `cproto "add"` (自动添加 .proto 扩展名)
- **完整文件名**: `cproto "add.proto"`
- **编译所有**: `cproto` (编译目录下所有 .proto 文件)

### 🔧 智能依赖处理
- 自动设置正确的 `--proto_path`，确保能找到所有导入的文件
- 支持跨目录的 proto 文件依赖关系
- 处理复杂的导入路径结构

### 🎯 多代码生成支持
自动生成以下代码：
- **Go 结构体**: `--go_out` 和 `--go_opt=paths=source_relative`
- **gRPC 服务**: `--go-grpc_out` 和 `--go-grpc_opt=paths=source_relative`
- **grpc-gateway**: `--grpc-gateway_out` 和 `--grpc-gateway_opt=paths=source_relative`

### 🌍 UTF-8 支持
- 自动设置控制台编码为 UTF-8
- 支持中文路径和文件名

## 使用方法

### 基本用法

```powershell
# 编译所有 proto 文件
cproto

# 编译单个文件（无扩展名）
cproto add

# 编译单个文件（带扩展名）
cproto add.proto

# 使用相对路径
cproto proto/book/book.proto

# 使用绝对路径
cproto "C:\path\to\file.proto"
```

### 高级用法

```powershell
# 编译多个文件
cproto book price author

# 指定 proto 目录
Compile-AllProtos -ProtoDir "custom_proto_dir" -Files @("file1", "file2")
```

## 工作场景

### 场景 1: 在 proto 根目录中
```
project/
    proto/          <- 当前位置
        service.proto
```
运行: `cproto service` 或 `cproto`

### 场景 2: 在项目根目录中
```
project/            <- 当前位置
    proto/
        service.proto
```
运行: `cproto` 或 `cproto proto/service`

### 场景 3: 在 proto 子目录中
```
project/
    proto/
        book/       <- 当前位置
            book.proto
            price.proto
        author/
            author.proto
```
运行: `cproto book` 或 `cproto` (编译当前目录所有文件)

### 场景 4: 复杂依赖关系
```
project/
    proto/
        book/
            book.proto      # 导入 "author/author.proto" 和 "book/price.proto"
            price.proto
        author/
            author.proto
```
运行: `cproto` (自动处理所有依赖关系)

## 输出示例

```
Compiling 3 proto file(s)...
  author.proto -> D:\project\proto\author
  [OK] author.proto
  book.proto -> D:\project\proto\book
  [OK] book.proto
  price.proto -> D:\project\proto\book
  [OK] price.proto
Compilation completed!
```

## 错误处理

### 文件未找到
```
Warning: File not found: nonexistent
No valid proto files found!
```

### 编译错误
```
  book.proto -> D:\project\proto\book
  [FAIL] book.proto (Exit code: 1)
    Proto root: D:\project\proto
    Input file: book/book.proto
```

### 目录未找到
```
Error: No proto directory found! Please run from project root or proto directory.
```

## 安装和配置

### 1. 确保已安装 protoc 和插件
```powershell
# 安装 protoc 编译器
# 从 https://github.com/protocolbuffers/protobuf/releases 下载

# 安装 Go 插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
```

### 2. 添加到 PowerShell 配置文件
函数已自动添加到您的 PowerShell 配置文件中，重启 PowerShell 或运行 `. $PROFILE` 即可使用。

## 别名
- `cproto` = `Compile-AllProtos`

## 技术实现

### 核心特性
1. **智能参数处理**: 自动识别用户意图，处理各种输入格式
2. **路径规范化**: 统一路径格式，确保跨平台兼容性
3. **依赖解析**: 智能计算 proto_path，确保导入正确解析
4. **错误友好**: 提供详细的错误信息和调试信息

### 兼容性
- ✅ Windows PowerShell 5.1+
- ✅ PowerShell Core 6.0+
- ✅ 支持中文路径和文件名
- ✅ 支持空格路径
- ✅ 跨驱动器路径支持

## 常见问题

### Q: 为什么编译失败？
A: 检查以下几点：
1. protoc 是否正确安装并在 PATH 中
2. 相关插件是否已安装
3. proto 文件语法是否正确
4. 导入路径是否正确

### Q: 如何处理复杂的导入关系？
A: `cproto` 会自动设置正确的 proto_path，通常不需要手动处理。确保所有相关的 proto 文件都在同一个 proto 根目录下。
