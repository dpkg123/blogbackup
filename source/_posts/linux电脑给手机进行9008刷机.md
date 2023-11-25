---
title: linux电脑给手机进行9008刷机
date: 2023-07-28 11:30:41
tags:
- 9008
- linux
- 刷机
summary:
---
# 准备工作
- 一台装有linux的电脑
- 一台能进入9008模式的手机
- 一双手
# 安装依赖
```
sudo apt install adb fastboot python3-dev python3-pip liblzma-dev git -y
```
# 安装驱动
```
sudo apt install libusb-dev -y
```
# 安装edl工具
### 克隆
执行
```
git --init --recursive clone https://github.com/bkerler/edl
```
### 复制规则
执行
```
sudo cp Drivers/51-edl.rules /etc/udev/rules.d
sudo cp Drivers/50-android.rules /etc/udev/rules.d
```
### 安装
执行
```
python3 setup.py build
sudo python3 setup.py install
```
# 使用edl工具箱
### 手机进入9008模式
执行
```
adb reboot edl
```
输入
```
edl
```
如无报错，证明连接成功。
### 刷入分区
这里以boot为例。
```
edl w boot boot.img
```
### 重启
执行
```
edl restart
```
