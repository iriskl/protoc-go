# 最终完善版本的 Proto 编译函数
function Compile-AllProtos {
    param(
        [string]$ProtoDir = $null,
        [string[]]$Files = @()
    )
    
    # 设置控制台编码为 UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    
    # 智能处理参数：如果 ProtoDir 看起来像文件名，将其移到 Files 中
    if ($null -ne $ProtoDir -and $ProtoDir -ne "" -and -not (Test-Path $ProtoDir -PathType Container)) {
        if ($Files.Count -eq 0) {
            $Files = @($ProtoDir)
            $ProtoDir = $null
        }
    }
    
    # 自动检测 proto 目录
    if ($null -eq $ProtoDir -or $ProtoDir -eq "") {
        $currentPath = Get-Location
        $currentDirName = Split-Path -Leaf $currentPath
        
        if (Test-Path "proto") {
            # 当前目录下有 proto 子目录
            $ProtoDir = "proto"
        } elseif ($currentDirName -eq "proto") {
            # 当前就在 proto 目录
            $ProtoDir = "."
        } else {
            # 检查是否在 proto 的子目录中
            $parentPath = $currentPath
            $foundProtoRoot = $false
            
            # 向上查找直到找到 proto 目录或到达根目录
            while ($parentPath -ne (Split-Path $parentPath -Parent)) {
                $parentPath = Split-Path $parentPath -Parent
                $parentDirName = Split-Path -Leaf $parentPath
                
                if ($parentDirName -eq "proto") {
                    $ProtoDir = "."
                    $foundProtoRoot = $true
                    break
                }
            }
            
            if (-not $foundProtoRoot) {
                Write-Host "Error: No proto directory found! Please run from project root or proto directory." -ForegroundColor Red
                return
            }
        }
    }
    
    # 确定 protoc 的根路径 - 最终修复版本
    if ($ProtoDir -eq ".") {
        # 如果当前在 proto 目录或其子目录，找到真正的 proto 根目录
        $currentPath = Get-Location
        $currentDirName = Split-Path -Leaf $currentPath
        
        if ($currentDirName -eq "proto") {
            # 当前就在 proto 根目录
            $protoRootPath = $currentPath.Path
        } else {
            # 在 proto 的子目录中，向上查找 proto 根目录
            $protoRootPath = $currentPath.Path
            $parentPath = $currentPath
            
            while ($parentPath -ne (Split-Path $parentPath -Parent)) {
                $parentPath = Split-Path $parentPath -Parent
                $parentDirName = Split-Path -Leaf $parentPath
                
                if ($parentDirName -eq "proto") {
                    $protoRootPath = $parentPath
                    break
                }
            }
        }
    } else {
        $protoRootPath = Join-Path (Get-Location) $ProtoDir
    }
    
    # 获取要编译的文件列表
    if ($Files.Count -gt 0) {
        # 用户指定了特定文件
        $protoFiles = @()
        foreach ($filePattern in $Files) {
            $resolvedFiles = @()
            
            if ([System.IO.Path]::IsPathRooted($filePattern)) {
                # 绝对路径
                if (Test-Path $filePattern) {
                    $resolvedFiles += Get-Item $filePattern
                }
            } elseif ($filePattern.Contains('\') -or $filePattern.Contains('/')) {
                # 相对路径
                $fullPath = Join-Path (Get-Location) $filePattern
                if (Test-Path $fullPath) {
                    $resolvedFiles += Get-Item $fullPath
                } elseif (-not $filePattern.EndsWith('.proto')) {
                    $protoPath = $fullPath + '.proto'
                    if (Test-Path $protoPath) {
                        $resolvedFiles += Get-Item $protoPath
                    }
                }
            } else {
                # 仅文件名，在当前目录或 proto 目录中查找
                if (Test-Path $filePattern) {
                    $resolvedFiles += Get-Item $filePattern
                } elseif (-not $filePattern.EndsWith('.proto')) {
                    $searchPath = $filePattern + '.proto'
                    if (Test-Path $searchPath) {
                        $resolvedFiles += Get-Item $searchPath
                    }
                }
                
                # 如果在当前目录没找到，尝试在 proto 目录中查找
                if ($resolvedFiles.Count -eq 0 -and $ProtoDir -ne ".") {
                    $searchPath = Join-Path $ProtoDir $filePattern
                    if (Test-Path $searchPath) {
                        $resolvedFiles += Get-Item $searchPath
                    } elseif (-not $filePattern.EndsWith('.proto')) {
                        $searchPath = Join-Path $ProtoDir ($filePattern + '.proto')
                        if (Test-Path $searchPath) {
                            $resolvedFiles += Get-Item $searchPath
                        }
                    }
                }
            }
            
            if ($resolvedFiles.Count -eq 0) {
                Write-Host "Warning: File not found: $filePattern" -ForegroundColor Yellow
            } else {
                $protoFiles += $resolvedFiles
            }
        }
        
        if ($protoFiles.Count -eq 0) {
            Write-Host "No valid proto files found!" -ForegroundColor Red
            return
        }
    } else {
        # 编译所有文件
        $protoFiles = Get-ChildItem -Path $ProtoDir -Filter "*.proto" -Recurse
        
        if ($protoFiles.Count -eq 0) {
            Write-Host "No .proto files found!" -ForegroundColor Yellow
            return
        }
    }
    
    Write-Host "Compiling $($protoFiles.Count) proto file(s)..." -ForegroundColor Cyan
    
    foreach ($file in $protoFiles) {
        $fileName = $file.Name
        $fileDir = $file.DirectoryName
        
        # 计算相对于 proto 根目录的输入路径
        $relativePath = if ($file.FullName.StartsWith($protoRootPath)) {
            $rootPathLength = $protoRootPath.Length
            if (-not $protoRootPath.EndsWith('\')) {
                $rootPathLength += 1  # 加上路径分隔符
            }
            $relPath = $file.FullName.Substring($rootPathLength)
            # 统一使用正斜杠，protoc 更喜欢这种格式
            $relPath -replace '\\', '/'
        } else {
            $fileName
        }
        
        Write-Host "  $fileName -> $fileDir" -ForegroundColor Gray
        
        # 统一使用 proto 根目录作为 proto_path，确保能找到所有导入
        & protoc --proto_path="$protoRootPath" --go_out="$protoRootPath" --go_opt=paths=source_relative --go-grpc_out="$protoRootPath" --go-grpc_opt=paths=source_relative --grpc-gateway_out="$protoRootPath" --grpc-gateway_opt=paths=source_relative "$relativePath"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] $fileName" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $fileName (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "    Proto root: $protoRootPath" -ForegroundColor DarkGray
            Write-Host "    Input file: $relativePath" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "Compilation completed!" -ForegroundColor Yellow
}

Set-Alias -Name cproto -Value Compile-AllProtos