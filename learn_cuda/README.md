# learn_cuda

默认已经在这个目录里：

```bash
cd /home/saimo/wangxiaolei/learn/learn_cuda
```

这个工程用 CMake 管理 CUDA demo。当前规则是：

- C++ 和 CUDA C++ 统一使用 C++20
- 递归扫描 `pmpp/`、`leetGPU/` 下的 `.cu` 文件
- 只有带 `main()` 的 `.cu` 文件会生成可执行文件
- 一个带 `main()` 的 `.cu` 对应一个可执行文件
- target 名包含父目录名，避免不同目录下同名文件冲突
- 可执行文件名包含 demo 子目录名和 `.cu` 文件原名，输出到各自 demo 根目录的 `bin/`

## 依赖

需要本机有这些工具：

- `cmake`
- `ninja`
- CUDA Toolkit / `nvcc`

工程内置 `third_party/fmt`，自动生成的 CUDA target 会默认链接 `fmt::fmt`。

当前 preset 使用：

```text
/usr/local/cuda/bin/nvcc
```

## clangd 与代码检查

首次打开工程或新增 CUDA demo 后，先生成 Debug 编译数据库：

```bash
cmake --preset debug
```

相关配置各自只负责一件事：

- `.clangd` 指向 `build/debug/compile_commands.json`，并把 NVCC 参数转换成 clangd 可解析的 CUDA 参数
- `.clang-tidy` 是 clangd 检查项的唯一配置来源
- `.vscode/settings.json` 启动 `/usr/bin/clangd-19` 并启用 clang-tidy
- `third_party/fmt` 使用它自己目录下更近的 `.clang-tidy`

修改这些配置后，在 VS Code 命令面板执行 `clangd: Restart language server`。普通 CMake
构建只生成编译数据库，不会额外执行独立的 `clang-tidy` 命令。

本机的 clangd 19 在 CUDA C++20 模式下会把合法的 `printf`、`malloc` 和 `free`
误判为 host/device 重载错误；NVCC 和 clang++ 19 的实际语法检查均能通过。配置没有
全局屏蔽“无匹配函数”诊断，以免隐藏真实错误；升级到支持 CUDA 12.8 的 clangd 后，
再同步修改 `.vscode/settings.json` 中的路径。

## 配置与编译

配置 Debug：

```bash
cmake --preset debug
```

编译 Debug：

```bash
cmake --build --preset debug
```

配置 Release：

```bash
cmake --preset release
```

编译 Release：

```bash
cmake --build --preset release
```

## 运行

编译后，可执行文件在：

```text
pmpp/bin/
leetGPU/bin/
```

例如：

```bash
./pmpp/bin/1.vecAdd_vector_add
./pmpp/bin/5.tiling_tiling2
./leetGPU/bin/1.vecAdd_vector_add
```

查看当前可用 target：

```bash
cmake --build --preset debug --target help
```

单独编译某个 target：

```bash
cmake --build --preset debug --target pmpp_5.tiling_tiling2
```

这里 target 名和可执行文件名是分开的：target 会带上 demo 根目录，例如 `pmpp_5.tiling_tiling2`；`bin/` 里的可执行文件不带根目录，但保留子目录前缀，例如 `5.tiling_tiling2`。

## 新增 CUDA demo

在 `pmpp/` 下新增 `.cu` 文件，并写入 `main()`：

```text
pmpp/6.example/example.cu
```

重新配置并编译：

```bash
cmake --preset debug
cmake --build --preset debug
```

如果 `.cu` 文件没有 `main()`，它不会自动生成可执行文件。

自动生成的 target 默认可以使用 `fmt`：

```cpp
#include <fmt/core.h>

fmt::print("value = {}\n", value);
```



cmake --preset debug
cmake --build --preset debug
nsys profile --trace=cuda,nvtx ./leetGPU/bin/2.matrix_multiplication_main
nsys stats report1.nsys-rep > result.txt
