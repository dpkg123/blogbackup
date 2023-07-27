---
title: linux解压payload.bin和转换system.new.dat.br
date: 2023-06-18 13:53:07
tags: 
- 刷机
- android
- linux
summary:
---

# 前排提示:
- 本图文基于debian12操作，其他操作系统仅供参考。
- 通用依赖: git python3

# 解包system.new.dat.br
理论上vendor.new.dat.br也可以这样做
安装brotli
```bash
sudo apt install brotli -y
 或
pip install brotli 
```
然后把system.new.dat.br和system.transfer.list放到一个文件夹中
输入
```bash
brotli -d system.new.dat.br
```
完成后会得到system.new.dat
然后克隆sdat2img
```bash
git clone https://github.com/xpirt/sdat2img
```
然后输入
```bash
python3 sdat2img/sdat2img.py system.transfer.list system.new.dat
```
就得到system.img

# 解包payload.bin

克隆
```bash
git clone https://github.com/vm03/payload_dumper

cd payload_dumper
pip install -r requirements.txt
```
注: debian12无法使用pip，可手动编译安装解决。
```bash
python3 payload_dumper.py ../payload.bin
```
最后会得到一堆img文件。
如果只提取单一分区的文件可以执行
```bash
python3 payload_dumper.py -partitions boot ../payload.bin 
```

