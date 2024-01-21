---
title: 简单写一个shell刷机脚本
date: 2023-04-29 14:26:36
tags:
- linux
- shell
- 刷机
---
# 前言
相比各种编程语言，linux shell脚本具有容易上手，运行速度快，轻量，跨架构运行，便于编写和测试等优点。如果想做的项目比较简单，或者你是没有编程经验的新手，那选择shell脚本应该会比较合适。
学会linux shell能做什么？可以完成大部分刷机操作的自动化，写各种一键工具等等。
linux shell简介
Shell是一个命令解释器，它解释由用户输入的命令并且把它们送到内核。不仅如此，Shell有自己的编程语言用于对命令的编辑，它允许用户编写由shell命令组成的程序。Shell编程语言具有普通编程语言的很多特点，比如它也有循环结构和分支控制结构等，用这种编程语言编写的Shell程序与其他应用程序具有同样的效果。
shell脚本是指后缀为.sh或其他后缀的脚本文件。新建一个txt文本文件并重命名为xxx.sh，就是创建了一个shell脚本。在shell脚本里，每一行字符就是一条命令，脚本开始运行后会从上到下逐行执行。shell脚本实际上就是文本，可以用任何文本编辑器编辑。
# 目标
确定一个目标是写shell脚本的第一步。本教程将带领大家完成一个最简单的fastboot刷入boot脚本。
命令简介
本教程用到的命令如下：
- echo :显示文字
- sleep :延迟多少时间后执行下一条指令
- fastboot flash xxx xxx.img:调用/usr/bin/fastboot刷入xxx.img
- if+else :如果表达式为真则表达if语句内的语句代码，否则表达else内的语句代码。
- exit: 退出脚本
# 实操
这里以debian 12和nano文本编辑器为例，其他操作系统仅供参考
新建一个文本文件并重命名为flash.sh
可以使用touch命令创建或者使用文本编辑器创建
```bash
$ touch flash.sh
```
或
``````bash
$ nano flash.sh
```
然后将要刷入的boot.img也放到同一个文件夹中。然后编辑flash.sh(如果使用文本编辑器创建的话会直接跳转到编辑界面)
然后在脚本第一行写
```bash
#!/bin/bash
```
第一行的内容指定了shell脚本解释器的路径，而且这个指定路径只能放在文件的第一行。第一行写错或者不写时，系统会有一个默认的解释器进行解释。
然后输入
```bash
echo 准备刷入boot
```
由于在linux shell上实现windows bat那样按任意键继续是比较困难的，这里使用sleep命令
输入
```bash
sleep 5s
```
这里的5s指的是在执行sleep命令多少时间后执行下一个命令
然后输入
```bash
/usr/lib/android-sdk/platform-tools/fastboot flash boot boot.img
```
这里是调用`/usr/lib/android-sdk/platform-tools/fastboot`完成刷入boot.img的操作，其中/usr/lib/android-sdk/platform-tools/fastboot是fastboot程序所在的位置，而/usr/bin/fastboot定向到/usr/lib/android-sdk/platform-tools/fastboot。当然直接写`fastboot`或者`/usr/bin/fastboot`也是可以的。
刷入完成后，最后再加上
```bash
exit 0
```
exit 0的意思是正常退出程序，当然写exit也行。不加的话，如果脚本后面没有内容的话也会自动退出。
当然如果你要把这个脚本放在别的机器上用的话可能会出现

```text
找不到命令 “fastboot”，但可以通过以下软件包安装它：
apt install fastboot
请联系您的管理员。
```
当然我这里是装了`command not found`软件包，如果不装的话就会出现
```text
fastboot:未找到命令
```
原因是机器上没有`/usr/bin/fastboot`
你也可以在文件夹里添加fastboot程序，只不过需要将fastboot程序设置为可执行权限并将脚本修改成
```bash
./fastboot flash boot boot.img
```
可以使用
```bash
chmod 755 fastboot
chmod +x fastboot
```
增加可执行权限
不过软件仓库里有我为什么还要附带
可以在脚本前面加上
```bash
sudo apt install fastboot -y
```
这里的 -y是确认安装fastboot软件包的意思。
如果不加-y的话,apt就会询问是否安装fastboot软件包
这里的sudo意思是用已认证的用户以root用户的身份执行命令，如果不加sudo的话apt会提示
```text
dpkg: 错误: 所请求的操作需要超级用户权限
错误：GDBus.Error:org.freedesktop.DBus.Error.Spawn.PermissionsInvalid: The permission of the setuid helper is not correct
E: Sub-process /usr/bin/dpkg returned an error code (2)
```
实际上apt是dpkg的前端而dpkg中的部分操作(安装，卸载，配置软件包等)是需要root权限的
如果你没有刷新软件仓库的话可能会提示

```text
正在读取软件包列表... 完成
正在分析软件包的依赖关系树... 完成
正在读取状态信息... 完成
E: 无法定位软件包 fastboot
```
所以需要在sudo apt install fastboot -y前面加上
```bash
sudo apt update
```
这个命令的意思是刷新软件源的意思，apt的索引文件存放于`/var/lib/apt/lists`

当然，这样的话无论你是否安装了fastboot软件包都会执行一遍sudo apt update
然后再执行一遍sudo apt install fastboot -y
为了避免这种情况的发生，我们需要检测是否安装fastboot软件包，如果安装了，则执行下一步操作。
这里使用if命令
if后面可以接选项，文件路径，也可以接命令
这里演示两种写法
一种是通过判断/usr/bin/fastboot是否存在然后执行下一步操作
```bash
if [ -d /usr/bin/fastboot ]
then
echo 
else
sudo apt update
sudo apt install fastboot -y
fi
echo 准备刷入boot
...
```
另一种是通过dpkg --list fastboot 来判断fastboot软件包是否安装,但是这样做的话无论是否安装fastboot软件包，都会显示dpkg的输出结果。
```bash
if dpkg --list fastboot
then
echo 
else
sudo apt update
sudo apt install fastboot -y
fi
echo 准备刷入boot
...
```
这里的语法意思是如果安装了fastboot就直接进行下一步操作，反之先刷新软件源列表，安装fastboot软件包，再执行下一步操作。

这样一个简单的刷入boot的脚本就完成了。
