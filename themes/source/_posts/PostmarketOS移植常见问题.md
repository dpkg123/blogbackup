---
title: PostmarketOS移植常见问题
date: 2023-04-24 21:30:12
tags:
- PostmarketOS
- ROM移植
---
# 前言
这篇文章简单介绍下我移植k20pro-PostmarketOS出现的问题以及解决方法
移植教程可以参考[这篇文章](https://ivonblog.com/posts/xperia5-ii-postmarketos-porting/)
注:以下问题需要执行`pmbootstrap log`才能找到，或者在pmbootstrap的工作目录里的`log.txt`里找到
建议编译内核前先删除pmbootstrap的工作目录里的`log.txt`

# 问题1: xxx patch无法打补丁
这个问题出现在执行`pmbootstrap kconfig edit`时
解决办法:
在`linux-xiaomi-raphael/APKBUILD`中删除所有.patch字样

# 问题2: asm/type.h :no such file or directory
这个问题出现在执行`pmbootstrap build linux-xiaomi-raphael`时
解决办法:
执行
```bash
$ pmbootstrap chroot
$ apk add linux-headers 
#注:第二条命令需要在第一条命令执行成功后再执行
```

# 问题3: gzip(cpio) command not found
同上
解决办法:
将上面的`linux-headers`换成gzip(cpio)

# 问题4 c语言错误
同上
解决办法:
如果你是c语言大佬，可以试试修复
否则尝逝更换编译器为`clang`
在`linux-xiaomi-raphael/APKBUILD`中添加以下字段
```text
CC="clang"
HOSTCC="clang"
```
或者使用gcc6/gcc4
在`linux-xiaomi-raphael/APKBUILD`中添加以下字段

```text
# Compiler: GCC 6 (doesn't boot when compiled with newer versions)
if [ "${CC:0:5}" != "gcc6-" ]; then
	CC="gcc6-$CC"
	HOSTCC="gcc6-gcc"
	CROSS_COMPILE="gcc6-$CROSS_COMPILE"
fi
```
如果要使用gcc4,请将上面字段的6改成4

如果还是不行的话，建议更换一个问题较少的内核~~这里着重点名小米，官方内核就是一坨shit~~
# 问题5: Permission denied
这个问题可能出现在执行`pmbootstrap build linux-xiaomi-raphael`或者`pmbootstrap install`的时候
解决办法:
换个目录并将目录权限设置成`755`
```bash
$ chmod 755 $(pmbootstrap_work_dir)
```

# 问题6: xxx.h no such file or directory
这个问题出现在执行`pmbootstrap build linux-xiaomi-raphael`时，且问题多出自与小米官方内核~~雷军，金凡！~~
解决办法:
使用find命令找到缺失的文件然后将文件复制到报错的文件的目录中

# 问题7:../include/linux/compiler-gcc.h:2:2: error: #error "Please don't include <linux/compiler-gcc.h> directly, include <linux/compiler.h> instead."
同上
解决办法:
将`APKBUILD`中的
```text
prepare() {
	default_prepare
	. downstreamkernel_prepare
}
```
换成
```text
prepare() {
	default_prepare
	REPLACE_GCCH=0
	. downstreamkernel_prepare
}
```
