---
title: OPPO Reno6 ColorOS13.1内核源码编译记录
date: 2024-01-15 15:03:25
tags:
 - android
 - kernel
 - OPPO
---
前几天看到[ OPPO 的 mt6877 源码](https://github.com/oppo-source/android_kernel_oppo_mt6877/)放出了[ Reno6 ColorOS13.1 分支](https://github.com/oppo-source/android_kernel_oppo_mt6877/tree/oppo/mt6877_t_13.1.0_reno6_5g)。遂拉下来编译。

## Config
首先需要知道 Reno6 ColorOS13.1 的内核用的是什么配置。

保险起见还是应该直接拿本机的 config 文件来进行编译。但是一方面 ColorOS13 太烂，烂的依托答辩。另一方面笔者没有解锁 Bootloader.而解锁又会清除数据。所以这条道路基本是行不通的。

根据查看本机信息得到 ColorOS 11.x/12.x 的内核版本是不变的，使用的配置均为 k6877v1_64_defconfig ，遂使用 k6877v1_64_k419_defconfig 来进行编译。

## 编译
这方面就没有啥太多想说的，无非就是安装依赖，拉取源码，然后写一个脚本编译然后就该干啥干啥了。

哦对了，如果要编译 OPLUS 内核的话，建议在 内核源码根目录的 nativefeatrues.memk 或者 oplus_native_features.mk 注释掉以下内容:

还有，如果是新机型的话，别忘了拉vendor源码。
``` bash Makefile
#OPLUS_FEATURE_SECURE_EXECGUARD=yes
#OPLUS_FEATURE_SECURE_GUARD=yes
#OPLUS_FEATURE_SECURE_KEVENTUPLOAD=yes
#OPLUS_FEATURE_SECURE_KEYINTERFACESGUARD=yes
#OPLUS_FEATURE_SECURE_MOUNTGUARD=yes
#OPLUS_FEATURE_SECURE_ROOTGUARD=yes
```
还要注释相关配置文件的内容:
``` bash defconfig
#ifdef CONFIG_OPLUS_SECURE_GUARD
CONFIG_OPLUS_ROOT_CHECK=y
CONFIG_OPLUS_EXECVE_BLOCK=y
CONFIG_OPLUS_MOUNT_BLOCK=y
CONFIG_OPLUS_SECURE_GUARD=y
#endif /*CONFIG_OPLUS_SECURE_GUARD*/
```
## fix
然而不出以为的话应该会出意外。

然后果然出意外了。

``` bash logcat
In file included from ../drivers/misc/mediatek/sensor/2.0/oplus_sensor_devinfo/oplus_sensor_feedback/sensor_feedback.c:24:
In file included from ../drivers/misc/mediatek/scp/rv/scp_helper.h:15:
../drivers/misc/mediatek/scp/rv/scp_feature_define.h:9:10: fatal error: 'scp.h' file not found
#include "scp.h"
         ^~~~~~~
1 error generated.
make[8]: *** [../scripts/Makefile.build:334: drivers/misc/mediatek/sensor/2.0/oplus_sensor_devinfo/oplus_sensor_feedback/sensor_feedback.o] Error 1
make[7]: *** [../scripts/Makefile.build:637: drivers/misc/mediatek/sensor/2.0/oplus_sensor_devinfo/oplus_sensor_feedback] Error 2
make[6]: *** [../scripts/Makefile.build:637: drivers/misc/mediatek/sensor/2.0/oplus_sensor_devinfo] Error 2
make[5]: *** [../scripts/Makefile.build:637: drivers/misc/mediatek/sensor/2.0] Error 2
make[4]: *** [../scripts/Makefile.build:637: drivers/misc/mediatek/sensor] Error 2
make[4]: *** Waiting for unfinished jobs....
  CC      drivers/misc/mediatek/scp/rv/scp_hwvoter_dbg.o
  AR      drivers/misc/mediatek/sspm/v2/built-in.a
  AR      drivers/misc/mediatek/sspm/built-in.a
  CC      drivers/spi/spi.o
  CC      drivers/spi/spi-mt65xx.o
  CC      drivers/spi/spi-mt65xx-dev.o
  AR      drivers/misc/mediatek/scp/rv/built-in.a
  AR      drivers/misc/mediatek/scp/built-in.a
make[3]: *** [../scripts/Makefile.build:637: drivers/misc/mediatek] Error 2
make[2]: *** [../scripts/Makefile.build:637: drivers/misc] Error 2
make[2]: *** Waiting for unfinished jobs....
```

遂通过 find 命令找到了该文件的位置:
``` bash find
drivers/misc/mediatek/scp/include/scp.h
```
于是就通过 ln 命令进行了软连接。考虑到头文件里可能还嵌入头文件，遂把剩下的头文件也 ln了过去。

你以为这就完了吗？

接着编译发现又出现了以下问题:
``` bash logcat
 DTC     arch/arm64/boot/dts/mediatek/oplus6877_20181.dtb
  AR      lib/crypto/built-in.a
../arch/arm64/boot/dts/mediatek/oplus6877_20181.dts:1039:10: fatal error: 'oplus6877_20181/cust.dtsi' file not found
#include "oplus6877_20181/cust.dtsi"
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~
1 error generated.
make[3]: *** [scripts/Makefile.lib:298: arch/arm64/boot/dts/mediatek/oplus6877_20181.dtb] Error 1
make[2]: *** [../scripts/Makefile.build:637: arch/arm64/boot/dts/mediatek] Error 2
make[1]: *** [arch/arm64/Makefile:153: dtbs] Error 2
make[1]: *** Waiting for unfinished jobs....
  CC      lib/fonts/fonts.o
  CC      lib/fonts/font_8x16.o
```

然而很抱歉，笔者翻阅了真我一加的 mt6877 源码后也没有找到这个文件，于是就注释掉了相关选项:
``` bash k6877v1_64_k419_defconfig
#CONFIG_BUILD_ARM64_APPENDED_DTB_IMAGE=y
#CONFIG_BUILD_ARM64_DTB_OVERLAY_IMAGE=y
#CONFIG_BUILD_ARM64_APPENDED_DTB_IMAGE_NAMES="mediatek/mt6877"
#CONFIG_BUILD_ARM64_DTB_OVERLAY_IMAGE_NAMES="mediatek/oplus6877_20181 mediatek/oplus6877_20181_v1 mediatek/oplus6877_20181_v2 mediatek/oplus6877_20181_v3 mediatek/oplus6877_20181_v4 mediatek/oplus6877_20355 mediatek/oplus6877_20355_v1 mediatek/oplus6877_20355_v2 mediatek/k6877v1_64_k419_dummy8 mediatek/oplus6877_21081  mediatek/oplus6877_212A1 mediatek/oplus6877_21851 mediatek/oplus6877_22612 mediatek/oplus6877_2169E mediatek/oplus6877_21711 mediatek/oplus6877_22710 mediatek/oplus6877_22633 mediatek/oplus6877_22037 mediatek/oplus6877_22277"
```
而且笔者也并没有在 arch/arm64/boot/Makefile 里找到有关于 Image.gz-dtb 和 dtbo 的内容。

最后编译出了 Image.gz 文件

``` bash logcat
  AR      drivers/misc/built-in.a
  AR      drivers/built-in.a
  GEN     .version
  CHK     include/generated/compile.h
  AR      built-in.a
  MODPOST vmlinux.o
WARNING: modpost: Found 1 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y'
  KSYM    .tmp_kallsyms1.o
  KSYM    .tmp_kallsyms2.o
  LD      vmlinux
  SORTEX  vmlinux
  SYSMAP  System.map
  OBJCOPY arch/arm64/boot/Image
  Building modules, stage 2.
  MODPOST 7 modules
WARNING: sound/soc/codecs/mt6357-accdet: 'accdet_read_audio_res' exported twice. Previous export was in vmlinux
WARNING: sound/soc/codecs/mt6357-accdet: 'accdet_late_init' exported twice. Previous export was in vmlinux
WARNING: sound/soc/codecs/mt6359-accdet: 'accdet_read_audio_res' exported twice. Previous export was in vmlinux
WARNING: sound/soc/codecs/mt6359-accdet: 'accdet_late_init' exported twice. Previous export was in vmlinux
  CC      drivers/video/backlight/lcd.mod.o
  CC      kernel/kheaders.mod.o
  CC      kernel/trace/trace_mmstat.mod.o
  GZIP    arch/arm64/boot/Image.gz
  CC      net/ipv4/tcp_htcp.mod.o
```
~~附: 笔者比对了 android_kernel_oppo_mtk_4.19 ，除了配置文件不一样，其他地方应该是相同的~~
