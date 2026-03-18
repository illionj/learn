# learn_cpp

默认你已经在这个目录里：

```bash
pwd
/home/saimo/wangxiaolei/learn/learn_cpp
```

后面的命令都以当前目录是 `learn_cpp` 为前提。

这个工程用 CMake 管理多个 C++ demo，当前默认配置是：

- 编译器：`clang++-19`
- 生成器：`Ninja`
- Debug 构建目录：`build/debug`
- Release 构建目录：`build/release`

## 依赖

需要本机有这些工具：

- `cmake`
- `ninja`
- `clang++-19`
- `clangd-19`
- `gdb`

## 终端中配置与编译

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

如果你执行：

```bash
cmake --build --preset debug
```

看到：

```text
ninja: no work to do.
```

这是正常的，表示当前没有需要重新编译的内容，不是报错。

## 终端中运行

当前可执行文件会生成在各自 preset 对应的 `build` 目录下。

例如 `miniTensor` 的 Debug 版本：

```bash
./build/debug/demos/1.miniTensor/miniTensor
```

如果以后 `demos/` 下有更多小项目，终端流程不变：

- 配置还是用 `cmake --preset ...`
- 编译还是用 `cmake --build --preset ...`
- 运行时只需要把可执行文件路径换成对应 demo 的路径

也就是说，不需要为每个 demo 重新发明一套编译和运行流程。

## 终端中调试

先确保 Debug 版本已经编译出来：

```bash
cmake --build --preset debug
```

这个工程的 Debug 构建默认会加上 `-gdwarf-4`，目的是兼容当前机器上的 `gdb 9.2`，保证可以按源码行调试。

然后直接用 `gdb` 调试可执行文件：

```bash
gdb ./build/debug/demos/1.miniTensor/miniTensor
```

进入 `gdb` 以后，常用命令如下：

- `break main`：在 `main` 下断点
- `run`：启动程序
- `continue`：继续运行到下一个断点
- `next`：单步越过
- `step`：单步进入
- `finish`：运行到当前函数返回
- `list`：查看当前断点附近源码
- `print 变量名`：打印变量值
- `info locals`：查看当前函数的局部变量
- `info breakpoints`：查看当前所有断点
- `delete 断点编号`：删除指定断点
- `delete`：删除全部断点
- `bt`：查看调用栈
- `frame`：查看当前栈帧
- `quit`：退出调试

一个最小示例：

```text
(gdb) break main
(gdb) run
(gdb) next
(gdb) bt
(gdb) quit
```

如果以后切换到别的 demo，调试流程也不变，只需要替换 `gdb` 后面的可执行文件路径。

## VS Code 补充

工作区已经配置了这些内容：

- `CMakePresets.json`
- `clangd`
- `tasks.json`

但主路径还是终端命令。

如果你在 VS Code 里操作：

- 可以直接 build 当前工程
- 可以运行 `run: active target (debug)`

这套配置的目的，是让你在保留终端工作流的同时，仍然可以在 VS Code 里直接触发配置、构建和运行。

## clangd 与格式化

- `.clangd` 会读取 `build/debug/compile_commands.json`
- `.clang-format` 负责代码格式化
- `.clang-tidy` 负责静态检查规则

如果你改了 CMake 配置，或者发现补全、跳转不对，先重新执行：

```bash
cmake --preset debug
```
