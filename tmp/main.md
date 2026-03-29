---
title: 为什么使用 TypeScript 写 Github Action 是愚蠢的
date: 2026-03-29 23:34:35
tags:
- TypeScript
- Action
summary: 写赛博真经，享创创人生。
---
在阅读这篇文章前，我默认你具有一定的 TypeScript 编程水平和 Git 运用水平，请知悉。

## Reusable Workflows 和 Shell
截取自[ray 的博客](https://blog.mk1.io/posts/2025/reusable-workflows#composite-actions-%E5%92%8C-reusable-workflows):
> 简单来说：Composite Actions 是复用多个步骤，例如设置运行时、安装依赖等；而 Reusable Workflows 则是复用整个工作流，包括触发条件、作业定义等（例如构建、测试、部署等）。

那么一句话来概括就是，action.yml 属于 Reusable Workflows，github/workflows/*.yml 属于 Composite Actions 。

为什么要强调这一点，因为我看到很多 fork 才能用的仓库竟然标榜自己是 action，我承认 github 有 actions 选项卡但是那个是 workflow。

再比如，workflow 可以发布到 market space，至于上文说的只有 Reusable Workflows 复用整个工作流，怎么说呢。虽然有 shellcheck action 这种复用的工作流。

Reusable Workflows 更多的是设置诸如构建依赖这种，如 setup-python，而 Composite Actions 主要是进行作业(例如语法检查)为主。

而 Reusable Workflows 的编写有多种方式，主流的有 Shell，Dockerfile 和 TypeScript. 本质上前两者属于一类，所以就一块说了。

Shell 编写的优点是简单，缺点就是语法检查。你不能用 shellcheck 去检查 yml 中 shell 的语法，而 yamllint 更多是基于符不符合 yaml 语法而不是去检查 shell 代码的合法性。

## 为什么要用 TypeScript 重写？
一开始是参考 Slinhub action 用 shell 写 action，每个步骤用 steps 隔开，然后发现这太不美观了，于是就用一个大的 step 包裹每个小 step，然后每个小 steps 用 start group end group 包裹，然后就因为加太多功能宕机了:

/home/runner/work/kernel_build_action/kernel_build_action/./action.yml (Line: 134, Col: 12): Exceeded max expression length 21000

那怎么办？在参考了 setup-python 的设计后了解了有一个 typescript-action 就决定用 TypeScript 重写了，之前有过为了写个人主页写 TypeScript 的经验，学了闭包和异步执行。但是觉得 async 太反人类了就作罢。最后个人主页用 v0.dev 糊了一版就扔到 vercel 上了，反正也没人看。

幸运的是，Github 有提供[模板](github.com/actions/typescript-action)，可以直接拿来用。

一般情况下只需要了解 core.getInput('foo') 获取 action.yml 里 inputs 里 foo 的值和  exec.exec("bar") 就可以写相当一部分有趣的东西了，不是吗？

## TypeScript 的坑
既然你都用 TypeScript 重写了，是不是得引入 lint 检查？例如 eslint 或者 biome？引入了 linter 是不是也得引入 formatter? 然后恭喜你你得自己配置 linter 和 formatter 然后陷入检查报错的循环中。

哪怕费劲千辛万苦解决了 linter 的问题，你是不是得配置一个 dependabot 或者 renovate 来检查库的更新啊？一般的 TypeScript 项目都配了你不能不配吧？

然后恭喜你，另一个坑又来了，actione/core^6.0.0 开始 ncc 构建失败，原因是 ncc 不能识别 core 里 package.json 的 export，那怎么办呢？烦请您换 esbuild 喽。

不换也行，继续老版本然后等着被 cve 攻击呗。

~~[骗你的，升级也会遇到 cve](https://www.cvedetails.com/cve/CVE-2026-26996/)~~

就算克服了这点困难，TypeScript 或者 JavaScript 语法也会带来理解上的灾难:

```TypeScript
export async function packageKernel(config: PackageConfig): Promise<void> {
  if (config.anykernel3) {
    await packageAnyKernel3(config);
  } else {
    await packageBootimg(config);
  }
}
```
等价于 Python:
```Python
def package_kernel(config: PackageConfig) -> None:
    if config.anykernel3:
        package_anykernel3(config)
    else:
        package_bootimg(config)
```
等价于 Go:
```Go
func packageKernel(config PackageConfig) error {
    if config.Anykernel3 {
        return packageAnyKernel3(config)
    }
    return packageBootimg(config)
}
```
等价于 Rust:
```Rust
pub fn package_kernel(config: PackageConfig) {
    if config.anykernel3 {
        package_anykernel3(config);
    } else {
        package_bootimg(config);
    }
}
```
看出来区别了吗？我要说的就是臭名昭著的 async ，你以为是同步，其实是异步执行只是看起来像同步哒！

而 Python 和 Rust 默认是同步的所以就用不着 async。

在 Reusable Workflows 的体系中，大部分过程都是串行执行的，即 setp a>step b

但是 nodejs ，或者是 JavaScript 的设计一开始就是异步模型的，在后续的发展中就形成了只要 await 就必须 async 的神经设计。

更搞笑的是 octokit 提供 python 和 ruby 的 sdk，而 actions 居然只有 TyoeScript 或者说类 JavaScript 系。

## 结论
没有结论，这篇文章就是我纯口嗨的。
