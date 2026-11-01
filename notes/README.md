# 学习笔记索引

每节课的讲解、和原生的对照、练习答案和踩过的坑都整理在这里。学习计划见 [PLAN.md](../PLAN.md)。

## 第 1 周：环境 + Dart 语言

| 天 | 主题 | 关键词 |
|---|---|---|
| [Day 1](week1/day1.md) | 搭环境 + 认识 Flutter | 自绘引擎、编译模式、热重载 vs 热重启、NDK 卡住排查 |
| [Day 2](week1/day2.md) | 变量、空安全、final 与 const | `const` 深度不可变与规范化、短路规则、`?[]`、`=>` |
| [Day 3](week1/day3.md) | 函数与类 | 命名参数、初始化列表、factory 缓存、`==`/`hashCode`、mixin 状态、extension 不提升 `this` |
| [Day 4](week1/day4.md) | 集合、records、sealed + 模式匹配 | collection if/for、`?x`、`sort` 原地修改、惰性 Iterable 重复计算、records 结构相等、穷尽性 switch、if-case、Map/列表模式 |
| [Day 5](week1/day5.md) | 异步：Future / Stream / Isolate | 事件循环两个队列、async 同步执行到首个 await、`(a, b).wait` 并发、`on Exception`、`await for` + break 取消、StreamController 自定义操作符（debounce）、`Isolate.run` |
| [Day 6](week1/day6.md) | 复盘：小测验 + 命令行记账 | 重定向构造函数、const 规范化 vs 不可变、`map().length` 不执行映射、用户输入别崩（`tryParse`）、列表模式解析命令、`?x` null-aware 元素、`.indexed`、可注入的 REPL |
