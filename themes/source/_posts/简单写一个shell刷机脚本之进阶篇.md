---
title: 简单写一个shell刷机脚本之进阶篇
date: 2023-04-29 14:42:10
tags:
- shell
- fastboot
- linux
- 刷机
---
[上一篇文章](https://dpkg123.github.io/2023/04/29/%E7%AE%80%E5%8D%95%E5%86%99%E4%B8%80%E4%B8%AAshell%E5%88%B7%E6%9C%BA%E8%84%9A%E6%9C%AC/)我们简单写了一个shell刷机脚本，这期我们要在上一期文章的基础上添加更多的操作
# 目标
- 创建两个选择，一个是刷入magisk-boot镜像，另一个是还原官方镜像
- 实现在开机状态下自动进入fastboot模式，在fastboot模式下自动执行指令
- 如果没解锁fastboot将提示无法刷写
注:为了方便，将会用`fastboot`取代`/usr/lib/android-sdk/platform-tools/fastboot`
# 使用的命令
命令太多就暂时不写了
# 实操
首先要确保magisk镜像叫`magisk-boot.img`，官方boot镜像叫`offical-boot.img`
首先输入
```bash
echo 这是一个简单的刷机脚本
```
为了美观可以在前面输入`clear或者reset`来清理屏幕
Tips:reset不是重启系统的命令,`reboot才是`，而且reboot命令需要root权限
然后输入
```bash
PS3='选择一项: '
```
这里设置PS3变量。 这是`select语句`在从我们的多选菜单中进行选择时使用的提示。
接下来创建预定选项列表。
```bash
options=("刷入magisk boot" "还原官方boot" "退出")
```
接下来，我们开始创建菜单的选择构造。 在这一行中，我们告诉select选择从options数组创建菜单。 我们还将在$menu变量中设置用户选择。 select语句的语法类似于for循环，这就是为什么您在末尾看到do语句的原因。
```bash
select menu in "${options[@]}"; do
```
使用case语句创建更多可靠的选项
case语句使您可以有选择地执行与第一个匹配模式相对应的命令。 例如，如果我们从多项选择菜单中选择第一项，它将执行与该单词相对应的命令列表。

在case语句中，我们有开头节。 这告诉案例搜索与$menu变量的值匹配的选项。
```bash
case $menu in
```
然后这里添加选项一的子句。
```bash
"刷入magisk boot")
            echo #这里的命令一会再回过头来修改
            ;;
```
这里的命令一会再回过头来修改，
执行完毕后，如果想直接退出脚本，可以在后面敲一行回车后输入
```bash
           break
```
然后如法炮制地添加第二三条选项即可。
tips:第三项是退出选项，只需要将echo和后面的换成`exit 0`即可。

如果输入了除了1,2,3以外的数字或字母将可能会导致脚本运行错误，这时候需要输入
```bash
 *) echo "未知选项 $REPLY";;
```
来告诉这是无效的输入
在所有子句之后，我们以esac结束case语句，`而esac是反写的的。 这类似于以fi结束if语句`。输入
```bash
esac
```
最后一行关闭用do打开的select语句。输入
```bash
done
```
到这时候，一个基本的选择页面就完成了。接下来我们回过头来修改之前选项里的内容
上期图文的脚本中我们只写了一个fastboot flash boot.img来刷写boot，虽然但是，改需要手动从开机页面重启到fastboot模式，很不方便。
于是可以使用if语句判断手机是否进入fastboot模式
```bash
if fastboot devices
then
adb reboot bootloader
else
fastboot flash boot magisk-boot.img
fastboot reboot
fi
```
当然如果想告诉用户刷入失败的原因的话可以整一个if嵌套循环。
```bash
adb devices
if [ $? -ne 0 ]
then
adb reboot bootloader
echo 即将刷入boot
sleep 5s
fastboot flash magisk-boot.img
if [ $? -ne 0 ]
then
fastboot reboot
exit 0
else
echo 刷入失败，请确保手机已解锁bootloader
exit 1
fi
else
echo 请确保手机已经开启usb调试且允许这台计算机进行调试
exit 1
fi
```
这里的`if [ $? -ne 0 ]`是用来判断上一条命令是否执行成功
`exit 1`的意思是非正常退出，与`exit 0`相反
Tips:if嵌套循环分开执行也是可以的。
if嵌套循环如果写错了就会产生这样的杯具
```text
flash.sh: 行 17: 未预期的记号 "fi" 附近有语法错误
flash.sh: 行 17: `fi'
```
还原官方boot同理，将`magisk-boot.img`字段替换成`offical-boot.img`即可

当然，为了防止`adb :command not found`出现，也可以在脚本上加入adb检测，只要将上篇文章的`sudo apt install fastboot -y`换成
`sudo apt install adb -y`即可
当然有些系统的adb不叫这个，例如termux上的adb软件包叫`android-tools`

