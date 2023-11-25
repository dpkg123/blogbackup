---
title: 3DS折腾linux小记
date: 2023-10-06 13:24:53
tags:
- 3DS
- linux
- buildroot
- kernel
summary:
---
为了使上下学路上不再无聊，笔者在某宝上淘了一台`B9S破解的老大三`(老3ds，不带任何后缀的那种)。熟悉我的人都知道，我经常在一些平台上折腾各种功能和工具，不是为了有多实用，而是为了测试和研究比较炫酷的东西。

于是乎就有了这篇文章。

### DS Linux

DSLinux的部署和使用相对容易很多，因为它提供了预编译的Linux文件系统和内核，也将启动文件打包成了.nds的格式。可以通过烧录卡或者TWilight Menu的方式启动DSLinux，在这里只介绍通过R4卡启动的方法，因为TWilight启动并不稳定，经常导致3DS系统崩溃并强制重启。

首先先在[DSLinux官网](http://www.dslinux.org/)上下载DLDI版本的DSLinux。将获得的文件解压并全部放在R4卡的Micro SD卡的根目录下。需要注意的是，请使用Linux系统进行解压和复制的操作，因为Windows下文件的结尾符与Linux并不相同，有的Windows解压工具也会忽略空目录，这些都会影响DSLinux的正常使用。在完成解压之后将R4卡重新装回3DS内，启动对应的入口程序进入R4菜单之后（这一步由于每个人使用的内核不一样，具体也略有不同），进入文件管理器，并且启动刚刚复制进去的.nds文件。之后DS模式会软重启并且加载DSLinux，DLDI版本的DSLinux能够自动登录，所以可以直接获取Shell。

![1](/img/20231006/1.jpg "DSLinux效果图")

不过由于这一移植系统的局限性，有些命令在这里不能使用。虽然文件系统被挂载为读写，而且有WiFi芯片的驱动(~~然而这并没有什么用，连xorg都没有~~)


### Linux for 3DS

Linux for 3DS是为原生3DS开发的一个Linux环境，使用的是Busybox+Buildroot的方式来获得Linux的指令集。

但是这一项目基本已经停止更新。

可以参考[GBATEMP上的一个帖子](https://gbatemp.net/threads/release-linux-for-the-3ds.407187/)以及[这个教程](https://firefox2100.github.io/kernel/2020/03/09/Linux_3DS/)

取下3DS的SD卡并连接电脑，（建议这种事还是把卡取下来，万一FTP传输的时候损坏文件比较麻烦）。在根目录下新建/linux文件夹，并在其中放入由arm9linuxfw编译获得的arm9linuxfw.bin，和由linux_3ds编译获得的./arch/arm/boot/zImage镜像和./arch/arm/boot/dts/nintendo3ds_ctr.dtb文件。之后将firm_linux_loader.firm放入/luma/payload内，插卡按住start开机，选择firm_linux_loader，等待其加载完成。

rootfs的用户名和密码都是root。

![2](/img/20231006/2.jpg "Buildroot")

### 引导其他linux

严格来说，这一Linux文件系统是Buildroot+busybox的方式。并不是所熟知的Linux。

所以笔者尝试构建了debian bullseye armel 和devuan chimaera armel的rootfs并启动他们，但是内核会panic:
![3](/img/20231006/3.jpg "panic")
或者卡在starting sysctl不动:
![4](/img/20231006/4.jpg "sysctl")
