# Flutter 两个月学习计划

- 学员背景：Android + iOS 原生开发
- 投入：每天约 1 小时，共 8 周（每周 5 天新内容 + 1 天复盘/练习 + 1 天休息）
- 开始日期：2026-10-27
- 主线项目：**GitHub 搜索客户端**（第 3 周起逐步搭建，第 8 周完成发布级版本）

## 学习方法

- 每天节奏：10 分钟回顾昨日 → 35 分钟学新内容并动手写代码 → 15 分钟练习/记笔记
- 每天开始时告诉我「Day N」，我会给出当天讲解、和原生的对照、以及练习题
- 写完的代码直接放在本目录，让我 review
- 每周复盘日：小测验 + 补漏
- 原则：**不重学你已经会的东西**。网络、架构、生命周期这些概念你都懂，我们只讲 Flutter 里「怎么做」和「哪里不一样」

## 目录约定

```
LearnFlutter/
  PLAN.md          本文件，完成一天勾一天
  notes/           每节课的笔记（README.md 是索引，weekN/dayM.md）
  dart_basics/     第 1 周 Dart 练习
  playground/      第 2~3 周 Widget 练习用的 Flutter 工程
  github_client/   主线项目
```

---

## 第 1 周：环境 + Dart 语言（对照 Kotlin / Swift）

- [x] Day 1 安装 Flutter SDK、配置 Android Studio / VS Code 插件、`flutter doctor` 全绿、跑起第一个 demo
- [x] Day 2 Dart 基础：变量、类型推断、空安全（对照 Kotlin `?` / Swift Optional）、`final` vs `const`
- [x] Day 3 函数与类：命名参数、构造函数花样（命名构造/工厂/初始化列表）、mixin、extension
- [x] Day 4 集合与函数式操作、`sealed class` + `switch` 模式匹配、records
- [x] Day 5 异步：`Future` / `async` / `await` / `Stream`、事件循环与 Isolate（对照协程 / Swift Concurrency）
- [x] Day 6 复盘：Dart 小测验 + 写一个命令行小程序

## 第 2 周：Widget 与布局

- [x] Day 1 一切皆 Widget：StatelessWidget、Widget 树、`build` 方法、热重载
- [ ] Day 2 布局三件套：Row / Column / Stack，Expanded / Flexible（对照 LinearLayout / UIStackView）
- [ ] Day 3 **约束模型**：Constraints go down, sizes go up, parent sets position（Flutter 布局最核心的一课）
- [ ] Day 4 常用组件：Container、Padding、Text、Image、Icon、Button、Material 3 主题
- [ ] Day 5 列表：ListView.builder、GridView、Sliver 入门（对照 RecyclerView / UITableView）
- [ ] Day 6 复盘：照着一个 App 截图还原一个页面

## 第 3 周：状态、交互与导航

- [ ] Day 1 StatefulWidget、`setState`、State 生命周期（对照 Activity / ViewController 生命周期）
- [ ] Day 2 输入与表单：TextField、TextEditingController、Form 校验、手势
- [ ] Day 3 导航：Navigator 1.0 基础 → go_router 声明式路由、传参与返回值
- [ ] Day 4 InheritedWidget 原理与 `BuildContext` 到底是什么
- [ ] Day 5 **主线项目启动**：创建 github_client，搭页面骨架（搜索页 / 详情页）
- [ ] Day 6 复盘：Key 的作用、常见 setState 坑

## 第 4 周：状态管理 + 网络

- [ ] Day 1 为什么需要状态管理；Provider 快速上手
- [ ] Day 2 Riverpod（推荐主力方案）：Provider 种类、`ref.watch` / `ref.read`
- [ ] Day 3 网络：http / dio、拦截器、错误处理
- [ ] Day 4 JSON 序列化：手写 `fromJson` → json_serializable / freezed + build_runner
- [ ] Day 5 主线项目：接入 GitHub Search API，加载/空/错误三态
- [ ] Day 6 复盘：分页加载、下拉刷新

## 第 5 周：持久化、架构与测试

- [ ] Day 1 本地存储：shared_preferences、文件、sqflite / drift
- [ ] Day 2 分层架构：Repository / Data / UI 分层（对照 Android 官方架构 / iOS MVVM）
- [ ] Day 3 单元测试与 Widget 测试
- [ ] Day 4 集成测试、mock（mocktail）
- [ ] Day 5 主线项目：收藏功能 + 本地持久化 + 补测试
- [ ] Day 6 复盘：代码 review 主线项目

## 第 6 周：和原生打交道（你的主场）

- [ ] Day 1 Platform Channel：MethodChannel / EventChannel，Kotlin 与 Swift 两端实现
- [ ] Day 2 Pigeon：类型安全的通道代码生成
- [ ] Day 3 编写一个 Flutter Plugin（Android + iOS 双端）
- [ ] Day 4 Add-to-App：把 Flutter 模块嵌入现有原生工程，FlutterEngine 预热与缓存
- [ ] Day 5 PlatformView：在 Flutter 里嵌原生 View；权限、生命周期对接
- [ ] Day 6 复盘：主线项目加一个原生能力（如系统分享 / 震动）

## 第 7 周：原理、动画与性能

- [ ] Day 1 三棵树：Widget / Element / RenderObject，一帧是怎么画出来的
- [ ] Day 2 隐式动画：AnimatedContainer、AnimatedSwitcher、Hero
- [ ] Day 3 显式动画：AnimationController、Tween、CustomPainter
- [ ] Day 4 DevTools：性能面板、rebuild 分析、内存
- [ ] Day 5 性能优化：const、RepaintBoundary、列表优化、Impeller 渲染引擎
- [ ] Day 6 复盘：给主线项目加转场动画并做一次性能检查

## 第 8 周：工程化与收尾

- [ ] Day 1 多环境配置（flavors）、国际化 intl
- [ ] Day 2 适配：深色模式、响应式布局、平板
- [ ] Day 3 打包发布：Android AAB 签名、iOS Archive、混淆与包体积
- [ ] Day 4 CI：GitHub Actions 跑 analyze + test + build
- [ ] Day 5 主线项目收尾与整体 review
- [ ] Day 6 结业：总结 + 后续进阶路线（Dart 3 新特性、Flutter Web/Desktop、开源阅读）
