---
title: fdt转dtb
date: 2023-04-30 23:03:54
tags:
- dtb
- android
---
# 从机器导出dtc
手机链接电脑，然后执行下列命令:(需要root)
```bash
$ adb shell su -c cp /sys/firmware/fdt /sdcard
$ adb pull /sdcard/fdr ./
```

# fdt转dts
执行
```bash
$ dtc -I dtb -O dts -o fdt.dts ./fdt
```

# dts转dtb
执行
```bash
$ dtc -I dts -O dtb -o fdt.dtb ./fdt.dts
```
