---
title: 使用netlify加快博客访问速度
date: 2023-04-12 11:24:39
tags:
- hexo
- github
- 网页加速
---
# 效果图

![效果图](/img/20230412/1.jpg "效果图")

# 准备工作

一个github账户
一个静态网站仓库
(可选)一个域名

# 前言(~~废话~~)

现在有越来越多的开发者选择把自己的博客以静态网站的方式托管在 GitHub 上, 这样的方式只需要一个域名就可以通过诸如 Jekyll, Hexo, 纸小墨 等等现有的静态博客生成工具, 非常便捷地搭建出一个样式美观的静态博客.

Github Pages免费且稳定的服务让我可以专注内容，而无需考虑成本及维护的问题，非常方便广受好评，但其最大的一个问题就是国内访问速度很慢，如何简单快速又低成本的解决这个问题呢？这里介绍一个服务：Netlify
# 什么是netlify

Netlify 是一个提供静态资源网络托管的综合平台，提供CI服务，能够将托管 GitHub，GitLab 等网站上的 Jekyll，Hexo，Hugo 等代码自动编译并生成静态网站。

Netlify 有如下的功能:

- 能够托管服务，免费 CDN 
- 能够绑定自定义域名
- 能够启用免费的TLS证书，启用HTTPS
- 支持自动构建
- 提供 Webhooks 和 API

# 登录netlify

打开netlity.com，点击`Get stared for free`按钮
![主页](/img/20230412/2.jpg "主页")
点击 `Sign in with Github`按钮
![登录](/img/20230412/3.jpg "登录")
然后同意授权
![授权](/img/20230412/4.jpg "授权")
![同意授权](/img/20230412/5.jpg "同意授权")
如果之前没有登录过github,会出现以下页面
![登录到github](/img/20230412/6.jpg "登录到github")
登录即可

# 使用netlify

进入空间管理中心，，点击`New site from git`按钮开始部署你的博客
然后根据自己的托管平台，可以选择GitHub、GitLab或者BitBucket（这里以 GitHub 为例）
点击GitHub之后会弹出一个让你授权的窗口，给 Netlify 授权后，就会自动读取你 GitHub 的仓库
选择仓库后，Netlify 会自动识别到 hexo，并填入相关信息，这时候只要无脑点击 `Deploy site`就可以了
稍等一段时间就可以看到你的博客已经部署成功，并且给你分配了一个二级域名。

# (可选)绑定域名

如果之前域名绑定了github,请在dns解析页面删除所有的github page解析


登录netlify，找到之前创建的网站
![网站](/img/20230412/7.jpg "网站")
点击`Site settings`
点击`General`下的`Domain management`
点击`Add domain alias`按钮添加域名
添加域名后，进入域名面板，点击`DNS解析`页面
根据提示添加netlify页面重定向
![DNS解析](/img/20230412/8.jpg "DNS解析")
添加成功后，回到netlify，会发现添加后的域名会变成绿色
![完成后的效果](/img/20230412/9.jpg "完成后的效果")

最后为自定义域名开启HTTPS支持，Domain management -> HTTPS，点击`Verify DNS configuration`，域名验证通过则会自动申请证书
至此Netlify与Github绑定完成，可以通过自定义域名访问网站了，之后你每一次提交代码到Github，便会自动发布至Netlify，无需额外操作，非常方便
