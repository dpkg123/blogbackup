---
title: 使用dh_make快速构建deb
date: 2023-06-22 13:34:29
tags:
- debian
- linux
summary:
---
注: 本方法适用于需要编译的项目
# 准备工作
以[ruri](https://github.com/moe-hacker/ruri)为例
克隆
```
git clone https://github.com/moe-hacker/ruri
```
安装编译所需依赖
```
sudo apt install dh_make dpkg-dev build-essential libcap-dev -y
```
删除.git文件夹
```
cd ruri
rm -rf .git
```
# 运行dh_make生成基本文件
```
dh_make --createorig -y -s -a -c apache -e Moe-hacker@outlook.com -p ruri
```

dh_make是一个用于创建Debian软件包的工具，它可以根据源代码生成debian目录和一些模板文件。dh_make的选项有以下几种：

- -e, --email <email>：指定维护者的电子邮件地址，如果不指定，则使用环境变量DEBEMAIL或EMAIL。
- -f, --file <file>：指定源代码的压缩文件，如果不指定，则使用当前目录下的第一个压缩文件。
- -n, --native：创建一个原生的Debian软件包，即没有上游的源代码。
- -s, --single：创建一个单一的二进制软件包，即只有一个deb文件。
- -i, --indep：创建一个独立的二进制软件包，即不依赖于架构的deb文件。
- -m, --multi：创建一个多个二进制软件包，即有多个deb文件。
- -l, --library：创建一个库软件包，即包含共享库或静态库的deb文件。
- -k, --kmod：创建一个内核模块软件包，即包含内核模块的deb文件。
- -b, --cdbs：使用cdbs（Common Debian Build System）来构建软件包，这是一种简化的构建系统。
- -r, --createorig：创建一个.orig.tar.gz文件，这是Debian软件包中用于存放上游源代码的压缩文件。
- -c, --copyright <name>：指定版权所有者的姓名，如果不指定，则使用环境变量DEBFULLNAME或NAME。
- -p, --packagename <name>：指定软件包的名称，如果不指定，则使用源代码目录的名称。
- -v, --version <version>：指定软件包的版本号，如果不指定，则使用源代码压缩文件中的版本号。
- -t, --templates <dir>:指定模板文件的目录，如果不指定，则使用/usr/share/dh-make/templates/目录。
- -d, --defaultless：不使用默认值来填充模板文件中的字段，而是让用户自己输入。
- -y, --yes：不询问用户任何问题，而是使用默认值或环境变量来填充模板文件中的字段。
- -h, --help：显示帮助信息并退出。

当前目录下会自动创建debian目录,目录下有很多打包使用的模板文件,以.ex/.EX结尾。可以删除换成自己的
# 修改文件
主要修改以下几个文件:
- postinst
可以用作者配置好的，如果没有可以不用填写
- changelog
参考以下格式: 
```
ruri (9.0) unstable; urgency=low

  * Initial release.

 -- Moe-hacker <Moe-hacker@outlook.com>  Mon, 19 Jun 2023 16:32:34 +0800
```
- copyright

一般不用修改。如果要往里添加的话参考
```
Files: src/riru
Copyright: 2023 Moe-hacker <moe-hacker@outlook.com>

License: Apache-2.0
```
- compat
一般为9,构建的时候可能会出现警告，调成10即可。
- rules
参考
```
#!/usr/bin/make -f
include /usr/share/dpkg/default.mk

%:
	dh $@ --parallel

override_dh_auto_configure:
	dh_auto_configure -- DEFINES+="VERSION=$(DEB_VERSION_UPSTREAM)"
```
- ruri.install

默认是没有这个文件的，需要手动创建。
建议先make一下。看看编译后生成的文件到底在哪。
ruri编译后默认生成到根目录
就可以写
```
ruri /usr/bin
```
- control
主要修改以下内容
Maintainer: 换成你自己的名字+你自己的邮箱，邮箱可以不填
Homepage: 项目主页
Depends: 所需要的依赖
Build-Depends: 编译所需要的依赖
Description: 描述
参考
```
ource: ruri
Priority: optional
Maintainer: Moe-hacker <Moe-hacker@outlook.com>
Build-Depends: debhelper-compat (= 13) ,clang ,build-essential ,libcap-dev
Standards-Version: 4.6.0
Homepage: https://github.com/Moe-hacker/ruri
Rules-Requires-Root: no

Package: ruri
Architecture: any
Depends: xz-utils
Description: chroot/unshare Linux containers
 simple & secure
```
# 打包deb
```
dpkg-buildpackage -b -us -uc
```
