---
title: 给OPPO Reno6移植kernelSU
date: 2023-05-10 20:14:10
tags:
- kernelSU
- linux
- 移植
- 内核编译
- Kernel
---
### KernelSU简介
# 什么是 KernelSU?
KernelSU 是 Android GKI 设备的 root 解决方案，它工作在内核模式，并直接在内核空间中为用户空间应用程序授予 root 权限
# 功能
KernelSU 的主要特点是它是基于内核的。 KernelSU 运行在内核空间， 所以它可以提供我们以前从未有过的内核接口。 例如，我们可以在内核模式下为任何进程添加硬件断点；我们可以在任何进程的物理内存中访问，而无人知晓；我们可以在内核空间拦截任何系统调用; 等等。

KernelSU 还提供了一个基于 overlayfs 的模块系统，允许您加载自定义插件到系统中。它还提供了一种修改 /system 分区中文件的机制。

### 构建支持kerbelSU的内核(使用官方内核源码)

# 配置环境和编译链
执行
```bash
$ sudo apt-get install libncurses5-dev libncurses-dev libssl-dev device-tree-compiler bc cpio lib32ncurses5-dev lib32z1 build-essential binutils bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev git
```
安装所需依赖

执行
```bash
$ git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 aarch64-linux-android-4.9 --depth=1
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 arm-linux-androideabi-4.9 --depth=1
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android12-release/clang-r383902.tar.gz ; tar -xvf clang*.tar.gz
```
安装编译环境

# 拉取内核源码(android12)

oppo reno6的官方源码: https://github.com/oppo-source/android_kernel_oppo_mt6877
通过wget的方式下载，直接git会丢文件
```bash
$ wget https://github.com/oppo-source/android_kernel_oppo_mt6877/archive/4a0cd0dd4399ed76c1d09b9bf6a218ccd0494f80.tar.gz ; tar -xvf 4a*.tar.gz
```
oppo reno6的附加源码: https://github.com/oppo-source/android_kernel_modules_oppo_mt6877
通过git或者wget下载都可以

# 拉取内核源码(android13)
与android12大同小异。
源码: https://github.com/oppo-source/android_kernel_oppo_mtk_4.19
附加模块: https://github.com/oppo-source/android_kernel_modules_oppo_mtk_4.19
另外需要手动复制vendor/oplus/kernel_4.19/audio到sound/soc/codecs目录
# 添加kernelSU
进入源码目录，执行`curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -`
# 编译
`将kernel source folder和kernel vendor source folder放在同一个目录下`，然后进入源码目录
然后配置编译参数,这里假设我的编译链放在内核源码的上一层目录
```bash
$ export  BUILD_CROSS_COMPILE=../aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CLANG_PATH=../clang/bin
export CROSS_COMPILE_ARM32=../arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
export ARCH=arm64
```
然后提取手机里的/proc/config.gz里的config文件，重命名为ksu_defconfig(需root)扔到arch/arm64/configs
如果没有的话可以使用oplus6877_defconfig
然后检查内核配置文件有没有启用kprobes,如果没有，需要启用他们
执行
```bash
$ make oplus6877_defconfig
make menuconfig
```
然后按/键搜索`kprobes`并启用他们。
或者在.config里添加
```txt
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_KPROBE_EVENTS=y
CONFIG_MODULES=y
```
然后执行
```bash
$ make
```
编译完成的内核文件在arch/arm64/boot目录


### 构建支持kerbelSU的内核(使用我提供的内核源码)

我提供的oppo reno6 内核源码: https://github.com/dabao1955/android_kernel_OPPO_PEQM00/
安卓版本为13
构建过程跟官方内核大同小异。不过相比之下有以下几点变更
- 需要将编译链放到家目录
- 进入内核目录需要执行setup.sh同步kernelsu
- 执行build.sh来编译内核

### 打包成卡刷文件

克隆anykernel3
```bash
$ git clone https://github.com/karthik558/AnyKernel3
```
删除以下目录或文件
- .git*
- dtbo.img
- f2fs*
- banner(可选)
- README.md
然后编辑anykernel.sh
修改以下内容
```txt
device.name(1-5)=
supported.versions=
```
然后使用zip命令打包
```bash
$ zip -r xxx.zip ./*
```

### 集成到boot.img
使用magiskboot
解包boot.img
```bash
$ magiskboot unpack boot.img
```
然后替换kernel并生成新的boot.img
```bash
$ magiskboot repack boot.img boot-1.img
```
