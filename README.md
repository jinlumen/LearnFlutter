# LearnFlutter

从 Android / iOS 原生转 Flutter 的 8 周学习记录（2026-10-27 开始，每天约 1 小时）。完整计划与进度见 [PLAN.md](PLAN.md)。

每节课的讲解、和原生的对照、练习答案和踩过的坑都整理在 [notes/](notes/) 里，目录如下。

## 第 1 周：环境 + Dart 语言

| 天 | 主题 | 练习 | 关键词 |
|---|---|---|---|
| [Day 1](notes/week1/day1.md) | 搭环境 + 认识 Flutter | [playground/](playground/) | 自绘引擎、编译模式、热重载 vs 热重启、NDK 卡住排查 |
| [Day 2](notes/week1/day2.md) | 变量、空安全、final 与 const | [day2.dart](dart_basics/day2.dart) | `const` 深度不可变与规范化、短路规则、`?[]`、`=>` |
| [Day 3](notes/week1/day3.md) | 函数与类 | [day3.dart](dart_basics/day3.dart) | 命名参数、初始化列表、factory 缓存、`==`/`hashCode`、mixin 状态、extension 不提升 `this` |
| [Day 4](notes/week1/day4.md) | 集合、records、sealed + 模式匹配 | [day4.dart](dart_basics/day4.dart) | collection if/for、`?x`、`sort` 原地修改、惰性 Iterable 重复计算、records 结构相等、穷尽性 switch、if-case、Map/列表模式 |
| [Day 5](notes/week1/day5.md) | 异步：Future / Stream / Isolate | [day5.dart](dart_basics/day5.dart) | 事件循环两个队列、async 同步执行到首个 await、`(a, b).wait` 并发、`on Exception`、`await for` + break 取消、StreamController 自定义操作符（debounce）、`Isolate.run` |
| [Day 6](notes/week1/day6.md) | 复盘：小测验 + 命令行记账 | [day6.dart](dart_basics/day6.dart) | 重定向构造函数、const 规范化 vs 不可变、`map().length` 不执行映射、用户输入别崩（`tryParse`）、列表模式解析命令、`?x` null-aware 元素、`.indexed`、可注入的 REPL |

## 第 2 周：Widget 与布局

| 天 | 主题 | 练习 | 关键词 |
|---|---|---|---|
| [Day 1](notes/week2/day1.md) | 一切皆 Widget | [w2d1.dart](playground/lib/w2d1.dart) | Widget 是不可变配置、三棵树预告、const 跳过重建、build 必须纯、拆类不拆方法、BuildContext、热重载不重跑初始化（顶层变量 / State 字段 / main）、`characters.first`、公有字段不提升 → if-case、第一次写 widget test |

## 目录结构

```
PLAN.md        8 周计划，完成一天勾一天
notes/         每节课的笔记（weekN/dayM.md）
dart_basics/   第 1 周 Dart 练习
playground/    第 2~3 周 Widget 练习用的 Flutter 工程
github_client/ 主线项目（第 3 周起）
```

## 运行练习

```bash
# 第 1 周 Dart 练习
dart run --enable-asserts dart_basics/day6.dart --test

# 第 2 周起的 Widget 练习（在 playground/ 下）
flutter test test/w2d1_test.dart
flutter run
```
