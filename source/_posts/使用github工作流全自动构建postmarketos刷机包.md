---
title: 使用github工作流全自动构建postmarketos刷机包
date: 2025-02-13 09:45:38
tags:
 - 手机
 - 刷机
 - Android
 - Root
 - Github
 - CI
 - Linux
summary:
---

## 前言
前几天我在给p maports 提交 PR 的时候偶然浏览了一下 PostmarketOS 的[构建工作流](https://build.postmarketos.org/)的配置文件的时候偶然发现了这行:
```bash
yes "" | pmbootstrap --aports=$PWD/pmaports -q init
```
我一直以为 yes 命令就是个不断输出 yes 的奇葩玩意儿，现在看来还可以通过管道符来实现自动输入的操作。
## 配置文件
让我们看看 pmbootstrap init 的流程:
```bash
user@pmos-build ~> pmbootstrap init
[19:23:28] Location of the 'work' path. Multiple chroots (native, device arch, device rootfs) will be created in there.
[19:23:28] Work path [/home/user/.local/var/pmbootstrap]: /home/user/pmwork
[19:23:46] Setting up the native chroot and cloning the package build recipes (pmaports)...
[19:23:46] Clone git repository: https://gitlab.com/postmarketOS/pmaports.git
正克隆到 '/home/user/pmwork/cache_git/pmaports'...
正在更新文件: 100% (6298/6298), 完成.
[19:24:54] NOTE: pmaports path: /usr/share/pmbootstrap/aports
[19:24:54] NOTE: you are using pmbootstrap version 1.50.1, but version 2.3.0 is required.
[19:24:54] ERROR: Please update your pmbootstrap version (with your distribution's package manager, or with pip,  depending on how you have installed it). If that is not possible, consider cloning the latest version of pmbootstrap from git.
[19:24:54] See also: <https://postmarketos.org/troubleshooting>
Run 'pmbootstrap log' for details.
```
稳定的其中一个坏处就是软件包太老，更何况 pmbootstrap 原来是可以通过 pip 安装的:
```bash
user@pmos-build ~> pip install pmbootstrap
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.

    If you wish to install a non-Debian-packaged Python package,
    create a virtual environment using python3 -m venv path/to/venv.
    Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
    sure you have python3-full installed.

    If you wish to install a non-Debian packaged Python application,
    it may be easiest to use pipx install xyz, which will manage a
    virtual environment for you. Make sure you have pipx installed.

    See /usr/share/doc/python3.11/README.venv for more information.

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```
虽然可以用 pipx 这样的方式来解决，但是我试过不知道为什么装不了。

或者直接克隆最新的 pmbootstrap 然后复制到 /usr/local/bin 里。

我一直认为 pmbootstrap 初始化后应该会保存配置的。因为你再执行一遍 pmbootstrap 的时候会显示你第一次配置过的选项。

然后我就在折腾管道符的时候知道了 --details-to-stdout 选项:

```bash
$ ~> printf "%s\n" "edge" "xiaomi" "raphael" "user" "xfce4" "n" "none" "en_US" "xiaomi-raphael" "y" | ./pmbootstrap/pmbootstrap.py -q init
[09:08:51] Location of the 'work' path. Multiple chroots (native, device arch, device rootfs) will be created in there.
[09:08:51] Setting up the native chroot and cloning the package build recipes (pmaports)...
[09:08:51] Clone git repository: https://gitlab.com/postmarketOS/pmaports.git
[09:08:49] Channel [edge]: [09:08:49] Vendor [qemu]: [09:08:49] Device codename [amd64]: [09:08:49] Kernel [lts]: [09:08:49] Username [user]: [09:08:49] Provider [default]: [09:08:50] User interface [console]: [09:08:50] Change them? (y/n) [n]: [09:08:50] Extra packages [none]: [09:08:50] Use this timezone instead of GMT? (y/n) [y]: [09:08:50] Locale [en_US]: [09:08:50] Device hostname (short form, e.g. 'foo') [qemu-amd64]: [09:08:50] Build outdated packages during 'pmbootstrap install'? (y/n) [y]: [09:08:51] Work path [/home/runner/.local/var/pmbootstrap]: Cloning into '/home/runner/work/repo/repo/edge/cache_git/pmaports'...
[09:08:56] Choose the postmarketOS release channel.
[09:08:56] Available (10):
[09:08:56] * edge: Rolling release / Most devices / Occasional breakage: https://postmarketos.org/edge
[09:08:56] * v24.06: Latest release / Recommended for best stability
[09:08:56] * v23.12: Old release (unsupported)
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: Invalid channel specified, please type in one from the list above.
[09:08:56] ERROR: EOF when reading a line
[09:08:56] See also: <https://postmarketos.org/troubleshooting>
[09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: [09:08:56] Channel [edge]: 
Run 'pmbootstrap log' for details.

Before you report this error, ensure that pmbootstrap is up to date.
Find the latest version here: https://gitlab.com/postmarketOS/pmbootstrap/-/tags
Your version: 3.0.0_alpha
```
然后使用 --details-to-stdout 选项运行:
```bash
[05:20:52] Pmbootstrap v3.0.0_alpha (Python 3.10.12 (main, Jul 29 2024, 16:56:48) [GCC 11.4.0])
[05:20:52] $ pmbootstrap ./pmbootstrap/pmbootstrap.py --details-to-stdout init
[05:20:52] Location of the 'work' path. Multiple chroots (native, device arch, device rootfs) will be created in there.
[05:20:52] Work path [/home/runner/.local/var/pmbootstrap]: [05:20:52] Work path [/home/runner/.local/var/pmbootstrap]: /home/runner/.local/var/pmbootstrap
[05:20:52] Save config: /home/runner/.config/pmbootstrap_v3.cfg
```
然后就找到了配置文件:
```toml
[pmbootstrap]
aports = /home/pmos/.local/var/pmbootstrap/cache_git/pmaports
device = xiaomi-raphael
is_default_channel = False
timezone = Asia/Shanghai
ui = xfce4
work = /home/pmos/.local/var/pmbootstrap

[providers]

[mirrors]
```
于是就有了一个大胆的想法:

我们可以先把配置文件放到指定目录然后再使用 yes 管道符进行全自动确认:
```yaml
- name: Initialize pmbootstrap
  run: |
     sudo aria2c  https://github.com/username/repo/raw/main/pmbootstrap_v3.cfg
     sudo mv pmbootstrap_v3.cfg -v /home/runner/.config/pmbootstrap_v3.cfg
     sudo chmod 777 -v /home/runner/.config/pmbootstrap_v3.cfg
     yes '' | ./pmbootstrap/pmbootstrap.py --details-to-stdout init
```
当然这种对于新设备来说是不使用的。

不过我们可以使用下面的方法进行初始化:
```yaml
- name: Initialize pmbootstrap
  run: |
     sudo chmod 777 -v /home/runner/.config/pmbootstrap_v3.cfg
     yes '' | ./pmbootstrap/pmbootstrap.py --details-to-stdout init
     sudo aria2c  https://github.com/username/repo/raw/main/pmbootstrap_v3.cfg
     sudo mv pmbootstrap_v3.cfg -v /home/runner/.config/pmbootstrap_v3.cfg
     mv *-xiaomi-raphael /home/pmos/.local/var/pmbootstrap/cache_git/pmaports/device/testing/ #假设已经通过 checkout 拉取了 pmos 的设备树
     yes '' | ./pmbootstrap/pmbootstrap.py --details-to-stdout init
```
