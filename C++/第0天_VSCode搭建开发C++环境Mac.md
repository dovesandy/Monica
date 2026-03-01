# 在 Mac 电脑上搭建 C++ 学习调试环境

## 目录

1. [环境准备](#环境准备)
2. [安装编译器](#安装编译器)
3. [安装 VS Code](#安装-vs-code)
4. [配置 VS Code 扩展](#配置-vs-code-扩展)
5. [创建和配置 C++ 项目](#创建和配置-c-项目)
6. [编译与调试](#编译与调试)
7. [高级配置](#高级配置)
8. [常见问题解决](#常见问题解决)

## 环境准备

### 系统要求

- **macOS 版本**: 10.14 (Mojave) 或更高版本
- **磁盘空间**: 至少 5GB 可用空间
- **内存**: 建议 8GB 或以上

### 检查现有开发工具

打开终端（Terminal），输入以下命令检查是否已安装开发工具：

``` bash
# 检查是否已安装 Command Line Tools

xcode-select -p

# 检查 Clang 编译器

clang --version
g++ --version
```

如果显示路径和版本信息，说明已安装，可跳过安装步骤。

## 安装编译器

### 方法一：安装 Xcode Command Line Tools（推荐）

1. 打开终端，执行以下命令：

``` bash
xcode-select --install
```

2. 会弹出安装对话框，点击"安装"

3. 同意许可协议

4. 等待安装完成（约10-30分钟）

### 方法二：安装完整 Xcode（可选）

1. 打开 App Store

2. 搜索 "Xcode"

3. 点击"获取"并安装

4. 安装完成后，打开 Xcode 并同意许可协议

### 验证安装

安装完成后，在终端验证：

``` bash
clang --version
g++ --version
make --version
```

应该显示类似以下的版本信息：

``` text
Apple clang version 14.0.0 (clang-1400.0.29.202)
Target: arm64-apple-darwin22.1.0
```

## 安装 VS Code

### 下载和安装

1. 访问 [VS Code 官网](https://code.visualstudio.com/)

2. 下载 macOS 版本（Universal 或 Apple Silicon）

3. 将下载的 .zip 文件解压，将 "Visual Studio Code.app" 拖到 "应用程序" 文件夹

4. 启动 VS Code

### 基础配置

1. **安装中文语言包**（可选）：

    - 打开扩展面板（`Cmd+Shift+X`）

    - 搜索 "Chinese (Simplified) Language Pack"

    - 安装并重启 VS Code

2. **推荐设置**（`Cmd+,` 打开设置）：

``` json
{
    "editor.fontSize": 14,
    "editor.tabSize": 2,
    "editor.wordWrap": "bounded",
    "files.autoSave": "afterDelay",
    "editor.formatOnSave": true,
    "C_Cpp.clang_format_style": "Google"
}
```

## 配置 VS Code 扩展

### 必需扩展

| 扩展名称 | 功能描述 | 安装命令 |
| --- | --- | --- |
| C/C++ | 提供 IntelliSense、调试支持 | ext install ms-vscode.cpptools |
| C/C++ Extension Pack | 包含常用 C++ 开发工具 | ext install ms-vscode.cpptools-extension-pack |
| Code Runner | 快速运行代码片段 | ext install formulahendry.code-runner |

### 安装步骤

1. 按 `Cmd+Shift+X` 打开扩展面板

2. 搜索上述扩展名称

3. 点击"安装"

### 配置 Code Runner

在设置中添加：

``` json

{
    "code-runner.runInTerminal": true,
    "code-runner.saveFileBeforeRun": true,
    "code-runner.executorMap": {
        "cpp": "cd $dir && g++ -std=c++17 $fileName -o $fileNameWithoutExt && $dir$fileNameWithoutExt"
    }
}
```

## 创建和配置 C++ 项目

### 创建项目结构

``` bash

# 在终端中创建项目目录
mkdir ~/cpp-learning
cd ~/cpp-learning
mkdir src include build

```

### 创建测试文件

创建 `src/main.cpp`：

``` cpp

# include <iostream>
# include <vector>

using namespace std;

int main() {
    cout << "🎉 Hello C++ on macOS!" << endl;

    vector<int> numbers = {1, 2, 3, 4, 5};
    cout << "Numbers: ";
    for (int num : numbers) {
        cout << num << " ";
    }
    cout << endl;
    
    return 0;
}
```

### 配置 VS Code 工作区

1. **创建 `.vscode` 文件夹**

2. **创建 `tasks.json`**（编译任务配置）：

``` json

{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "clang++",
            "args": [
                "-std=c++17",
                "-stdlib=libc++",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/../build/${fileBasenameNoExtension}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always"
            },
            "problemMatcher": ["$gcc"]
        }
    ]
}
```

3. **创建 `launch.json`**（调试配置）：

``` json

{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C++ Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/../build/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "build",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing",
                    "text": "type format add --format value --value-string "${var}" --summary-string "${var}"",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}

```

4. **创建 `c_cpp_properties.json`**（IntelliSense 配置）：

``` json
{
    "configurations": [
        {
            "name": "Mac",
            "includePath": [
                "${workspaceFolder}/**",
                "/usr/include",
                "/usr/local/include"
            ],
            "defines": [],
            "macFrameworkPath": [
                "/System/Library/Frameworks",
                "/Library/Frameworks"
            ],
            "compilerPath": "/usr/bin/clang",
            "cStandard": "c17",
            "cppStandard": "c++17",
            "intelliSenseMode": "macos-clang-arm64"
        }
    ],
    "version": 4
}

```

## 编译与调试

### 方法一：使用 VS Code 内置功能

1. **编译**：按 `Cmd+Shift+B`

2. **调试**：按 `F5` 或点击调试图标

3. **运行**：右键选择 "Run Code"（如果安装了 Code Runner）

### 方法二：使用终端

``` bash

# 进入项目目录
cd ~/cpp-learning

# 编译
clang++ -std=c++17 -stdlib=libc++ -g src/main.cpp -o build/main

# 运行
./build/main

# 调试
lldb build/main

```

### 调试技巧

1. **设置断点**：点击行号左侧

2. **查看变量**：调试时在左侧"变量"面板查看

3. **监视表达式**：在"监视"面板添加要监视的变量

4. **调用堆栈**：查看函数调用关系

## 高级配置

### 使用 Makefile（推荐用于多文件项目）

创建 `Makefile`：

``` makefile

CXX = clang++
CXXFLAGS = -std=c++17 -stdlib=libc++ -g -Wall
SRCDIR = src
INCDIR = include
BUILDDIR = build
SOURCES = $(wildcard $(SRCDIR)/*.cpp)
OBJECTS = $(SOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)
TARGET = $(BUILDDIR)/main

$(TARGET): $(OBJECTS)
 $(CXX) $(CXXFLAGS) $^ -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp
 @mkdir -p $(BUILDDIR)
 $(CXX) $(CXXFLAGS) -I$(INCDIR) -c $< -o $@

clean:
 rm -rf $(BUILDDIR)

.PHONY: clean

```

### 使用 Homebrew 安装额外工具

``` bash


# 安装 Homebrew（如果尚未安装）
/bin/bash -c "$(curl -fsSL <https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh>)"

# 安装现代 C++ 编译器（可选）
brew install gcc
brew install llvm

# 安装构建工具
brew install cmake
brew install ninja

```

## 常见问题解决

### 1. "xcode-select: error: tool 'xcodebuild' requires Xcode"

**解决方案**：

``` bash

sudo xcode-select --switch /Library/Developer/CommandLineTools

### 2. 编译器找不到头文件

__解决方案__：检查 `c_cpp_properties.json` 中的 includePath 配置

### 3. 调试器无法启动

```

**解决方案**：

- 确认已安装 Xcode Command Line Tools

- 检查 `launch.json` 中的程序路径是否正确

### 4. 权限问题

**解决方案**：

``` bash

# 给编译出的可执行文件添加执行权限
chmod +x build/main

```

### 有用的终端命令

``` bash

# 查找编译器路径
which clang
which g++

# 查看 macOS 版本
sw_vers

# 查看处理器架构
uname -m

# 查看已安装的 SDK
xcodebuild -showsdks

```

## 学习资源

- [Apple Developer Documentation](https://developer.apple.com/documentation/)

- [LLDB 调试器教程](https://lldb.llvm.org/use/tutorial.html)

- [C++ Reference](https://en.cppreference.com/w/)

- [VS Code 官方 C++ 教程](https://code.visualstudio.com/docs/languages/cpp)
