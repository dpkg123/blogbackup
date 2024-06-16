---
title: 本地搭建第三方alpine repo
date: 2024-03-22 19:48:45
tags:
 - alpine
 - linux
 - 软件源
summary:
---
警告: 本文章可能会出现部分没说清楚的地方，欢迎补充。

## 准备工作
 - 一个 alpine 容器
 - 一双手

## 安装依赖
``` bash
$ sudo apk add abuild
```

## 编写 APKBUILD
一个简单的 APKBUILD 示例:
``` bash APKBUILD
# Maintainer: username <username@mail.com>
pkgname=project
pkgver=x.x.x
pkgrel=x
pkgdesc=""
url="https://github.com/username/project"
arch="aarch64"
_carch="arm64"
license="Apache-2.0"
makedepends="
        bash
        go
        ...
"

# Source
source="
        v0.56.0.tar.gz::https://github.com/username/project/archive/refs/tags/v0.56.0.tar.gz"

builddir="$srcdir/$pkgname-$pkgver"

prepare() {
        ./configure --prefix="$pkgdir"
}

build() {
        make
}

package() {
	make install
}


sha512sums="
"
```
一些常见的选项解释:
- pkgname 软件包名称
- pkgver 软件包版本
- pkgrel 软件的附加版本，例如这里的 `lzip (1.24.1-r0)`:
``` bash
user@localhost ~/a/s/frp (main)> sudo apk add abuild
fetch https://mirrors.bfsu.edu.cn/alpine/edge/main/aarch64/APKINDEX.tar.gz
fetch https://mirrors.bfsu.edu.cn/alpine/edge/community/aarch64/APKINDEX.tar.gz
(1/9) Installing attr (2.5.2-r0)
(2/9) Installing libcap-getcap (2.69-r1)
(3/9) Installing fakeroot (1.33-r0)
(4/9) Installing lzip (1.24.1-r0)
(5/9) Installing openssl (3.2.1-r0)
(6/9) Installing patch (2.7.6-r10)
(7/9) Installing pkgconf (2.1.1-r0)
(8/9) Installing abuild (3.12.0-r5)
Executing abuild-3.12.0-r5.pre-install
(9/9) Installing abuild-sudo (3.12.0-r5)
Executing busybox-1.36.1-r19.trigger
OK: 164 MiB in 103 packages
```
- pkgdesc 软件包描述
- url 项目网址，可以贴github项目
- arch 目标架构，可以通过查看[软件源](https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community/)得知
- license 软件许可
- makedepends 构建所需依赖
- source 软件源码获取，只支持.tar.gz格式，例如:
``` bash
source="
        xxx.tar.gz::<源码下载url>"
```
- builddir 编译软件包的目录，例如如果要在xxx文件夹下编译就写xxx
- prepare函数 可以填写在编译前的一些前置依赖构建，例如
``` bash
prepare() {
	go mod download
}
```
这样就可以在准备阶段下载go软件包
- build函数 一般填写编译指令，例如 make
- install函数 一般填写安装指令，例如 make install
- sh512sums 使用 abuild checksum自动填充:
``` bash
user@localhost ~/a/s/frp (main)> abuild checksum
>>> frp: Fetching v0.56.0.tar.gz::https://github.com/fatedier/frp/archive/refs/tags/v0.56.0.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 1054k    0 1054k    0     0   467k      0 --:--:--  0:00:02 --:--:-- 1291k
>>> frp: Updating the sha512sums in /home/user/alpine-software-repos/source/frp/APKBUILD...
```

当然也可以编写例如post-install脚本来在安装后进行一些初始化功能。
### 一些常见变量的解释

- $srcdir 一般为自动设定
- $pkgname APKBUILD 中设定的软件包名
- $pkgver APKBUILD 中设定的软件包版本

## 构建
执行
``` bash
abuild -r
```
构建的软件包在用户文件夹下的package文件夹
下面是一个详细的构建流程，以构建frp为例:
``` bash logcat
user@localhost ~/a/s/frp (main)> sudo abuild -r -f -F
>>> frp: Building source/frp 0.56.0-r0 (using abuild 3.12.0-r5) started Sat, 23 Mar 2024 23:38:40 +0800
>>> frp: Checking sanity of /home/user/alpine-software-repos/source/frp/APKBUILD...
>>> frp: Analyzing dependencies...
>>> frp: Installing for build: build-base bash go wget
WARNING: opening /root/packages//source: No such file or directory
(1/18) Installing jansson (2.14-r4)
(2/18) Installing zstd-libs (1.5.5-r9)
(3/18) Installing binutils (2.42-r0)
(4/18) Installing libgomp (13.2.1_git20240309-r0)
(5/18) Installing libatomic (13.2.1_git20240309-r0)
(6/18) Installing gmp (6.3.0-r0)
(7/18) Installing isl26 (0.26-r1)
(8/18) Installing mpfr4 (4.2.1-r0)
(9/18) Installing mpc1 (1.3.1-r1)
(10/18) Installing gcc (13.2.1_git20240309-r0)
(11/18) Installing libstdc++-dev (13.2.1_git20240309-r0)
(12/18) Installing musl-dev (1.2.5-r0)
(13/18) Installing g++ (13.2.1_git20240309-r0)
(14/18) Installing fortify-headers (1.1-r3)
(15/18) Installing build-base (0.5-r3)
(16/18) Installing binutils-gold (2.42-r0)
(17/18) Installing go (1.22.1-r1)
(18/18) Installing .makedepends-frp (20240323.153842)
Executing busybox-1.36.1-r19.trigger
OK: 542 MiB in 121 packages
>>> frp: Cleaning up srcdir
>>> frp: Cleaning up pkgdir
>>> frp: Cleaning up tmpdir
>>> frp: Fetching v0.56.0.tar.gz::https://github.com/fatedier/frp/archive/refs/tags/v0.56.0.tar.gz
>>> frp: Fetching v0.56.0.tar.gz::https://github.com/fatedier/frp/archive/refs/tags/v0.56.0.tar.gz
>>> frp: Checking sha512sums...
v0.56.0.tar.gz: OK
>>> frp: Unpacking /var/cache/distfiles/v0.56.0.tar.gz...
go fmt ./...
env CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -tags frps -o bin/frps ./cmd/frps
go version go1.22.1 linux/arm64
env CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -tags frpc -o bin/frpc ./cmd/frpc
>>> WARNING: frp: APKBUILD does not run any tests!
    Alpine policy will soon require that packages have any relevant testsuites run during the build process.
    To fix, either define a check() function, or declare !check in $options to indicate the package does not have a testsuite.
mkdir: created directory '/home/user/alpine-software-repos/source/frp/pkg/frp/etc'
mkdir: created directory '/home/user/alpine-software-repos/source/frp/pkg/frp/etc/frp'
--2024-03-23 23:39:49--  https://github.com/fatedier/frp/raw/dev/conf/frpc_full_example.toml
Resolving github.com (github.com)... 28.0.0.144
Connecting to github.com (github.com)|28.0.0.144|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/fatedier/frp/dev/conf/frpc_full_example.toml [following]
--2024-03-23 23:39:52--  https://raw.githubusercontent.com/fatedier/frp/dev/conf/frpc_full_example.toml
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 28.0.2.190
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|28.0.2.190|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 12411 (12K) [text/plain]
Saving to: '/home/user/alpine-software-repos/source/frp/pkg/frp/etc/frp/frpc.toml'

/home/user/alpine-r 100%[===============================>]  12.12K  --.-KB/s    in 0.002s

2024-03-23 23:39:54 (7.84 MB/s) - '/home/user/alpine-software-repos/source/frp/pkg/frp/etc/frp/frpc.toml' saved [12411/12411]

--2024-03-23 23:39:54--  https://github.com/fatedier/frp/raw/dev/conf/frps_full_example.toml
Resolving github.com (github.com)... 28.0.0.144
Connecting to github.com (github.com)|28.0.0.144|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/fatedier/frp/dev/conf/frps_full_example.toml [following]
--2024-03-23 23:39:58--  https://raw.githubusercontent.com/fatedier/frp/dev/conf/frps_full_example.toml
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 28.0.2.190
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|28.0.2.190|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 6162 (6.0K) [text/plain]
Saving to: '/home/user/alpine-software-repos/source/frp/pkg/frp/etc/frp/frps.toml'

/home/user/alpine-r 100%[===============================>]   6.02K  --.-KB/s    in 0.001s

2024-03-23 23:40:01 (7.36 MB/s) - '/home/user/alpine-software-repos/source/frp/pkg/frp/etc/frp/frps.toml' saved [6162/6162]

>>> frp: Running postcheck for frp
>>> frp: Preparing package frp...
>>> frp: Stripping binaries
>>> frp: Scanning shared objects
>>> frp: Tracing dependencies...
>>> frp: Package size: 31.8 MB
>>> frp: Compressing data...
>>> frp: Create checksum...
>>> frp: Create frp-0.56.0-r0.apk
>>> frp: Build complete at Sat, 23 Mar 2024 23:40:08 +0800 elapsed time 0h 1m 28s
>>> frp: Cleaning up srcdir
>>> frp: Cleaning up pkgdir
>>> frp: Uninstalling dependencies...
(1/18) Purging .makedepends-frp (20240323.153842)
(2/18) Purging build-base (0.5-r3)
(3/18) Purging g++ (13.2.1_git20240309-r0)
(4/18) Purging libstdc++-dev (13.2.1_git20240309-r0)
(5/18) Purging gcc (13.2.1_git20240309-r0)
(6/18) Purging binutils (2.42-r0)
(7/18) Purging libatomic (13.2.1_git20240309-r0)
(8/18) Purging libgomp (13.2.1_git20240309-r0)
(9/18) Purging fortify-headers (1.1-r3)
(10/18) Purging go (1.22.1-r1)
(11/18) Purging binutils-gold (2.42-r0)
(12/18) Purging isl26 (0.26-r1)
(13/18) Purging jansson (2.14-r4)
(14/18) Purging mpc1 (1.3.1-r1)
(15/18) Purging mpfr4 (4.2.1-r0)
(16/18) Purging musl-dev (1.2.5-r0)
(17/18) Purging zstd-libs (1.5.5-r9)
(18/18) Purging gmp (6.3.0-r0)
Executing busybox-1.36.1-r19.trigger
OK: 164 MiB in 103 packages
>>> frp: Updating the source/aarch64 repository index...
>>> frp: Signing the index...
```
## 搭建软件源 
创建文件夹
``` bash
$ mkdir -p /var/www/root/alpine
```
初始化新的APK仓库

``` bash
apk index -o APKINDEX.tar.gz /var/www/root/alpine/*.apk
```

开启nginx
``` bash
nginx -s reload
```
