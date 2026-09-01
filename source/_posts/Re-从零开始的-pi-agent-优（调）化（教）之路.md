---
title: 'Re: 从零开始的 pi agent 优（调）化（教）之路'
date: 2026-09-01 15:07:20
tags:
- pi
- agent
summary: 你是谁？请支持 pi coding agent!
---

在用了一段时间后，感觉 pi 是越来越得心应手力！（喜）

自从 iflow 停止服务后我就一直接入别的第三方模型用的 iflow，它那个简洁的ui 和计划模式和 yolo 模式我很喜欢，但是有几个槽点：
- 切换模型需要重新填模型 id，不能一键切换
- 部分模型调用工具失败
- 默认输出的 AGENTS.md 有点太长了
- 以及最重要的，不开源且停止维护，就有点，诶

总之我比较满意，然后在 mzw 的推荐下又跑去用 opencode 了 (

一开始配置完模型后确实比较满意，默认的 plan/build 特别好用，输出的 AGENTS.md 也比较简洁。然后用一段时间后就出现了两个问题:
- 烫烫烫
- 卡卡卡，一看 opencode 吃了快 7 8 个g 了，最牛的一次直接给系统干死机了
这两点叠加后带来的后果就是续航哗哗掉。然后风扇噪音特别大

然后一时半会还找不到替代品，就打算这么用下去，直到我看到了:

https://linux.do/t/topic/2293134

就中午开始决定折腾 pi 了。当然这个更偏向于流水账这样。

## UI 和插件

我当然对 pi 默认的 ui 是不太满意的，就参考了 https://linux.do/t/topic/2621784 给出的界面[自己搓了一个](https://github.com/NekoSekaiMoe/pi-packages/blob/main/packages/pi-ui)。

![界面1](https://github.com/NekoSekaiMoe/pi-packages/raw/main/packages/pi-ui/Screenshot_2026-08-29-16-46-08-45_84d3000e3f4017145260f7618db1d683.jpg)
![界面2](https://github.com/NekoSekaiMoe/pi-packages/raw/main/packages/pi-ui/Screenshot_2026-08-29-16-15-41-08_84d3000e3f4017145260f7618db1d683.jpg)

大体就是 底下界面仿 opencode，状态栏随意发挥，工具调用全都仿 codex，这么捏出来的一个四不像。

关于其他插件：
- subagents 方面，觉得[原版 pi subagents](https://github.com/edxeth/pi-subagents)太臃肿了干脆换成了[下游的 fork](https://github.com/narumiruna/pi-extensions) 并开启了精简模式。
- 网页搜索方面，同样觉得 pi-web-access 太臃肿了，换成自己写的了，用[exa 的免费额度](https://exa.ai/) 也不是不能用
- 对话回滚，用的是 pi-rewind，特别好用
- 提问方面，用的是 @juicesharp/rpiv-ask-user-question 但是精简了提示词
- todo 方面，用的是 @zhushanwen/pi-todo
- mcp 方面，用的是 pi-mcp-adaptor，用于连接 gotls，typescript-language-server，clangd 和 pylsp。
- 上下文压缩方面，一开始用的是 pi-context-prune。后来听 mzw 说默认压缩也可以用就干脆换成默认压缩了。

大头讲完了，剩下的小头呢，pi-simplity 用于清理死代码。@juicesharp/rpiv-advusor 用于提交 pr 前的同行评审。我自己编写的 pi-extra-cmd 则是提供了三个参数：
- /init，提取的 codex 的 init 文本，用于生成 AGENTS.md.
- /context，查看上下文具体占用明细
- /exit，同 /quit.

然后就是 pi fake codex，这个就是从请求头到工具调用都尽可能 codex 化以应对中转站的检测。pi-smart-flow-lite 用于提供 bash_bg 进行后台运行指令而不堵塞 agent loop 本身。

关于我自己写的 package，可以从 https://github.com/NekoSekaiMoe/pi-packages 中获取。

至于其他方面，goal 插件没装，感觉用不到。plan mode 同样没装。所以权限什么的也没装。默认就是 yolo mode。运行这么多天以来没见过误删文件的情况。

实测下来，north mini code 输入你好回应后的 system prompt 占用 6.2k，muse spark 1.2 contributors 占用 7.8k。这样。

现在我的 coding agent 除了 pi 以外就剩一个特别难用的 antigravity 用于使用 gemini 模型了。主要是我权益在主号，而且听说反代容易封号就没弄。
