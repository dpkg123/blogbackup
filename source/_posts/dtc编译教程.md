---
title: dtc编译教程
date: 2024-01-29 15:26:53
tags:
 - android
 - dtc
 - linux
 - dtb
---
> 警告:本文章是给 arm64 linux 准备的。

## 安装依赖
直接从 lineageOS 依赖抄一份就行了。

除此之外还要安装以下东西:

- bison
- pkg-config
- libyaml-dev

## 下载源码
``` bash
wget https://android.googlesource.com/platform/external/dtc/archive/refs/heads/android11-release.tar.gz -o dtc.tar.gz
```
如果要下载其他版本就把 android11 改成 android[版本号] 就行。最低为 android10.

## 解压
```
tar -xzf dtc.tar.gz 
```

## 编译
然后直接编译即可。编译后会生成 dtc 文件。
```
make dtc -j8
```
## debug
这里阐述下遇到的问题:

### make: *** 没有规则可制作目标“dtc-parser.h”，由“dtc-lexer.lex.o” 需求。 停止。 
``` bash logcat
         BISON dtc-parser.tab.c
dtc-parser.y: 警告: 3 项偏移/归约冲突 [-Wconflicts-sr]
dtc-parser.y: note: rerun with option '-Wcounterexamples' to generate conflict counterexamples
         LEX dtc-lexer.lex.c
         DEP treesource.c
         DEP livetree.c
         DEP fstree.c
         DEP flattree.c
         DEP dtc.c
         DEP data.c
         DEP checks.c
         DEP convert-dtsv0-lexer.lex.c
         DEP dtc-parser.tab.c
         DEP dtc-lexer.lex.c
         CC srcpos.o
         CC util.o
         CC convert-dtsv0-lexer.lex.o
         CC dtc.o
         CC checks.o
         CC data.o
         CC flattree.o
         CC fstree.o
         CC livetree.o
         CC treesource.o
make: *** 没有规则可制作目标“dtc-parser.h”，由“dtc-lexer.lex.o” 需求。 停止。
make: *** 正在等待未完成的任务....
```
解决方法: 手动执行
``` bash
bison -d dtc-parser.y -o dtc-parser.h
```
然后有可能遇到以下错误:
``` bash logcat
         DEP dtc-parser.tab.c
         DEP dtc-lexer.lex.c
         CC dtc-lexer.lex.o
         CC dtc-parser.tab.o
         LD dtc
/bin/ld: dtc-parser.tab.o:/home/user/rootfs/android10/dtc-parser.tab.c:1086: multiple definition of `yylloc'; dtc-lexer.lex.o:/home/user/rootfs/android10/dtc-lexer.l:41: first defined here
collect2: 笨蛋！ld 返回 1
make: *** [Makefile:312：dtc] 错误 1
```
解决办法: 删掉 dtc-parser.tab.c 第1086行。
曾经也试过将 `YYLTYPE yylloc` 改成 `extern YYLTYPE yylloc` ，但是会出现以下问题:
``` bash logcat
         DEP dtc-parser.tab.c
         CC dtc-parser.tab.o
dtc-parser.tab.c:1086:16: 笨蛋！对‘yylloc’冗余的重声明 [-Werror=redundant-decls]
 1086 | extern YYLTYPE yylloc
      |                ^~~~~~
In file included from dtc-parser.tab.c:112:
dtc-parser.tab.h:131:16: 才...才不会告诉你...：‘yylloc’的前一个声明
  131 | extern YYLTYPE yylloc;
      |                ^~~~~~
cc1：所有的警告都被当作是错误
make: *** [Makefile:316：dtc-parser.tab.o] 错误 1
```
