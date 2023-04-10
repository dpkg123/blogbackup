---
title: hexo博客源码备份
date: 2023-04-10 17:46:16
tags:
- hexo
- web前端
- github
---

# 前言
作为一个写代码的人来说，保存和备份是非常重要的，所以随手保存和存有备份已经成为我的习惯了。使用Hexo在github搭建的博客，仓库里只有生成的静态网页文件，是没有Hexo的源文件的，所以如何备份就成为了一个重要的问题，这篇文章便应运而生了

# 方法1 

找到你的博客目录
```bash
$ tar -cvf blogbackup.tar.gz blogbackup
```
这里的blogbackup为你的博客源码文件夹名称
然后将备份完之后的压缩包上传到网盘

# 方法2

cd到博客源码文件夹，首先执行
```bash
$ hexo cl
```
清理生成完毕的网页

接下来在github新建一个仓库，假设这里的仓库地址为`https://github.com/xxx/blogbackup`

然后执行
```bash
$ git clone https://github.com/xxx/blogbackup
```
会提示
```text
正克隆到 'blogbackip'...
警告：您似乎克隆了一个空仓库。
```
将文件放入此目录然后提交即可
