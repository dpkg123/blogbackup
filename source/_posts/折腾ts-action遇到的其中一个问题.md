---
title: 折腾ts action遇到的其中一个问题
date: 2024-02-11 22:01:08
tags:
 - TypeScript
 - Github Actions
---
### 问题
这是一个简单的ts示例:

``` bash TypeScript
import os from "os";
import * as core from "@actions/core";
import * as io from "@actions/io";
import * as exec from "@actions/exec";

async function post(): Promise<void> {
    if (await io.which("$HOME/gcc-64/bin")) {
        await exec.exec("HOME/gcc-64/bin/aarch64-linux-android-as --version");
        return;
    } else if (await io.which("$HOME/clang/bin/clang")) {
        await exec.exec("$HOME/clang/bin/clang --version");
        return;
    }
}

(async () => {
    try {
        await post();
    } catch (error) {
        console.log("Failed to run post step.");
        return 1;
    }
})();
```

请分析当编译成cjs时运行node index.js时当$HOME/clang和$HOME/gcc-64都不存在时是否会报错。

### 解答


答案:不会。

假设`io.which`方法正常工作，如果两个路径`$HOME/gcc-64/bin`和`$HOME/clang/bin`都不存在，则`io.which`返回的是`undefined`或者`false`，因此两个条件判断都不满足，函数将直接结束执行，并不会执行`await exec.exec(...)`语句，也就不会抛出错误。

在这种情况下，如果`io.which`方法和`exec.exec`方法实现都是正确的，只有在尝试执行不存在的路径时才会报错。但代码中并没有提供发生错误时的处理，只是在最外层的自调用匿名函数中捕获异常，并打印“Failed to run post step.”。如果异常未被内部`try-catch`正确处理，确实会导致运行时报错。

因此，如果其他部分实现正确，环境不存在导致的错误会被内部逻辑处理，不会向用户抛出异常。

解决方法:
将
``` bash TypeScript
console.log("Failed to run post step.");
        return 1;
```
改成
``` TypeScript
console.error("Failed to run post step.");
        process.exit(1);
```
