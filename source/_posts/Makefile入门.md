---
title: Makefile入门
date: 2023-08-04 16:56:05
tags:
- linux
- makefile
summary:
---
本文章旨在教会一个新用户学会编写makefile.

在了解makefile之前，我们需要知道make是什么。

# make命令简介

make是一个在软件开发中所使用的工具程序（Utility software），经由读取“makefile”的文件以自动化建构软件。它是一种转化文件形式的工具，转换的目标称为“target”；与此同时，它也检查文件的依赖关系，如果需要的话，它会调用一些外部软件来完成任务。它的依赖关系检查系统非常简单，主要根据依赖文件的修改时间进行判断。大多数情况下，它被用来编译源代码，生成结果代码，然后把结果代码连接起来生成可执行文件或者库文件。它使用叫做“makefile”的文件来确定一个target文件的依赖关系，然后把生成这个target的相关命令传给shell去执行。

~~由此可见，Makefile可以抽象理解为有make这个解释器去执行的shell脚本~~

运行make help，输出结果如下:

```
user@localhost ~ >  make help

用法：make [选项] [目标] ...
选项：
  -b, -m                      为兼容性而忽略。
  -B, --always-make           无条件制作 (make) 所有目标。
  -C 目录, --directory=目录    在执行前先切换到 <目录>。
  -d                          打印大量调试信息。
  --debug[=旗标]               打印各种调试信息。
  -e, --environment-overrides
                              环境变量覆盖 makefile 中的变量。
  -E 字串, --eval=字串        将 <字串> 作为 makefile 语句估值。
  -f 文件, --file=文件, --makefile=文件
                              从 <文件> 中读入 makefile。
  -h, --help                  打印该消息并退出。
  -i, --ignore-errors         忽略来自命令配方的错误。
  -I 目录, --include-dir=目录  在 <目录> 中搜索被包含的 makefile。
  -j [N], --jobs[=N]          同时允许 N 个任务；无参数表明允许无限个任务。
  -k, --keep-going            当某些目标无法制作时仍然继续。
  -l [N], --load-average[=N], --max-load[=N]
                              在系统负载高于 N 时不启动多任务。
  -L, --check-symlink-times   使用软链接及软链接目标中修改时间较晚的一个。
  -n, --just-print, --dry-run, --recon
                              只打印命令配方，不实际执行。
  -o 文件, --old-file=文件, --assume-old=文件
                              将 <文件> 当做很旧，不必重新制作。
  -O[类型], --output-sync[=类型]
                           使用 <类型> 方式同步并行任务输出。
  -p, --print-data-base       打印 make 的内部数据库。
  -q, --question              不运行任何配方；退出状态说明是否已全部更新。
  -r, --no-builtin-rules      禁用内置隐含规则。
  -R, --no-builtin-variables  禁用内置变量设置。
  -s, --silent, --quiet       不输出配方命令。
  --no-silent                 对配方进行回显（禁用 --silent 模式）。
  -S, --no-keep-going, --stop
                              关闭 -k。
  -t, --touch                 touch 目标（更新修改时间）而不是重新制作它们。
  --trace                     打印跟踪信息。
  -v, --version               打印 make 的版本号并退出。
  -w, --print-directory       打印当前目录。
  --no-print-directory        关闭 -w，即使 -w 默认开启。
  -W 文件, --what-if=文件, --new-file=文件, --assume-new=文件
                              将 <文件> 当做最新。
  --warn-undefined-variables  当引用未定义变量的时候发出警告。

该程序为 aarch64-unknown-linux-gnu 编译
报告错误到 <bug-make@gnu.org>
```

Make命令依赖这个文件进行构建。Makefile文件也可以写为makefile， 或者用命令行参数指定为其他文件名。

例如

```
make -f Makefile.txt
```

# Makefile基本语法

Makefile的编写一般遵循以下规则:

```
<target> : <prerequisites> 
[tab]  <commands>
```
target也就是一个目标文件，可以是Object File，也可以是执行文件。还可以是一个标签（Label）。

prerequisites就是，要生成那个target所需要的文件或是目标。

command也就是make需要执行的命令。（任意的Shell命令）

prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。

下面是一个简单的Makefile示例。

```
build: src
	gcc -c src/main.c -o src/main.o
clean: src/main.o
	rm -rf src/main.o
```

# Makefile扩展语法

### Makefile手动变量

下面是一个Makefile的一部分:

```
build: src
	cd src
	gcc -c main.c -o main.o
	gcc -c ui.c -o ui.o
	gcc -c src.c -o src.o
```
我们可以看到[.o]文件的字符串被重复了三次，如果我们的工程需要加入一个新的[.o]文件，那么我们需要在三个地方加（应该是四个地方，还有一个地方在clean中，这里并没有展示）。当然，我们的makefile并不复杂，所以在两个地方加也不累，但如果makefile变得复杂，那么我们就有可能会忘掉一个需要加入的地方，而导致编译失败。所以，为了makefile的易维护，在makefile中我们可以使用变量。makefile的变量也就是一个字符串，理解成C语言中的宏可能会更好

比如，我们声明一个变量，叫objects, OBJECTS, objs, OBJS, obj, 或是 OBJ。我们在makefile一开始就这样定义:
```
objects = main.o src.o ui.o
outs : $(objects)
```

于是，我们就可以很方便地在我们的makefile中以“$(objects)”的方式来使用这个变量了。

```
	gcc -o outs $(objects)
```
同理。我们也可以使用系统自带变量。

有些有默认值，有些没有。比如常见的几个：

> CPPFLAGS : 预处理器需要的选项 如：-I 
> CFLAGS：编译的时候使用的参数 –Wall –g -c 
> LDFLAGS ：链接库使用的选项 –L -l

### Makefile自动变量

Makefile提供了很多自动变量，但常用的为以下三个。这些自动变量只能在规则中的命令中使用，其它地方使用都不行。

- $@ --> 规则中的目标

- $< --> 规则中的第一个依赖条件

- $^ --> 规则中的所有依赖条件

例如:

```
app: main.c func1.c fun2.c ​gcc $^ - o $@
```
其中：$^表示main.c func1.c fun2.c，$<表示main.c，$@表示app。

### Makefile模式规则

模式规则是在目标及依赖条件中使用%来匹配对应的文件，比如在目录下有main.c, src.c, ui.c三个文件，对这三个文件的编译可以由一条规则完成：

```
%.o:%.c ​ $(CC) –c $< -o $@
```
这条模式规则表示：

main.o由main.c生成， ​ src.o由src.c生成， ​ src.o由src.c生成

### Makefile 目标
一般来说，make的最终目标是makefile中的第一个目标，而其它目标一般是由这个目标连带出来的。这是make的默认行为。当然，一般来说，你的makefile中的第一个目标是由许多个目标组成，你可以指示make，让其完成你所指定的目标。要达到这一目的很简单，需在make命令后直接跟目标的名字就可以完成（如前面提到的“make clean”形式）

任何在makefile中的目标都可以被指定成终极目标，但是除了以“-”打头，或是包含了“=”的目标，因为有这些字符的目标，会被解析成命令行参数或是变量。甚至没有被我们明确写出来的目标也可以成为make的终极目标，也就是说，只要make可以找到其隐含规则推导规则，那么这个隐含目标同样可以被指定成终极目标。

使用指定终极目标的方法可以很方便地让我们编译我们的程序，例如下面这个例子：

```
.PHONY: all
all: arg1 arg2 arg3
```
从这个例子中，我们可以使用“make all”命令来编译所有的目标（如果把all置成第一个目标，那么只需执行“make”），我们也可以使用 “make prog2”来单独编译目标“prog2”。

即然make可以指定所有makefile中的目标，那么也包括“伪目标”，于是我们可以根据这种性质来让我们的makefile根据指定的不同的目标来完成不同的事。

下面请看这个例子

```
claen: out
	rm -rf out
```
如果当前目录下存在名为clean的文件，则该命令不执行。

最稳妥的做法是下面这样:

```
.PHONY : clean

clean :
	-rm -rf out
```
.PHONY意思表示clean是一个“伪目标”，伪目标一般没有依赖的文件。而在rm命令前面加了一个小减号的意思就是，也许某些文件出现问题，但不要管，继续做后面的事。当然，clean的规则不要放在文件的开头，不然，这就会变成make的默认目标。

### Makefile返回值
一般地，Makefile有三个返回值:
- 0 —— 表示成功执行。
- 1 —— 如果make运行时出现任何错误，其返回1。
- 2 —— 如果你使用了make的“-q”选项，并且make使得一些目标不需要更新，那么返回2。

实际上一个Makefile可能不仅只有这三个返回值。

### 引进其他Makefile
只需要在Makefile开头加入
```
include <src/Makefile>
```

### Makefile判断

请看下面的例子:

```
ifeq ($(CC),gcc)
  ld=$(ld)
else
  ld=$(ld.lld)
endif
```

上面代码判断当前编译器是否 gcc ，然后指定不同ld。
