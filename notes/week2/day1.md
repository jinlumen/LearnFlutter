# 第二周 Day 1：一切皆 Widget

日期：2026-11-02　练习：[playground/lib/w2d1.dart](../../playground/lib/w2d1.dart)　测试：[playground/test/w2d1_test.dart](../../playground/test/w2d1_test.dart)

运行：在 `playground/` 下执行 `flutter test test/w2d1_test.dart`；看界面效果用 `flutter run`（`main.dart` 的 `home` 指向 `W2D1Page`）。

## 1. Widget 不是 View，而是一份「配置」

| | Android View / UIView | Flutter Widget |
|---|---|---|
| 本质 | 重对象，一直存活，状态可变（`setText()`） | **不可变**的轻量描述，用完即丢 |
| 更新 UI | 拿到引用去改它 | 重新 `build` 出一份新配置，由框架比对差异 |
| 最接近的东西 | — | Compose 的 `@Composable`、SwiftUI 的 `View` struct |

**三棵树**（第 7 周细讲）：

- **Widget**：蓝图，也就是你写的 `Text('hi')`。
- **Element**：挂在树上的实例，记录这个节点在树里的位置。
- **RenderObject**：负责布局和绘制。

结论：Widget 很便宜，扔掉重建是常态。

## 2. StatelessWidget 的三条规矩

```dart
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name}); // const 构造
  final String name;                              // 字段全是 final
  @override
  Widget build(BuildContext context) => ...;      // 返回子树
}
```

1. **字段全是 `final`**：Widget 不可变，会变的东西放到 StatefulWidget 的 State 里（W3D1 讲）。
2. **尽量写 `const` 构造，子 widget 也尽量 `const`**：`const SizedBox(width: 8)` 在整个程序里是同一个实例（W1D6 讲过的 const 规范化）。框架发现新旧 widget `identical`，就直接跳过这棵子树。
3. **`build` 必须是纯函数**：热重载、父节点重建、主题变化、旋转屏幕都会触发它。build 里不能发请求，不能修改传进来的数据，也不要做重计算。类比 SwiftUI 的 `body`，或者 Compose 函数体里不能有副作用。

**组合优于继承**：不会有人去 `extends Text`，都是把 widget 包起来用。拆子组件时，**优先拆成新的 Widget 类，而不是写 `Widget _buildHeader()` 这样的辅助方法**。拆成类有三个好处：可以 `const`、有自己的 `BuildContext`、能成为独立的重建边界。

## 3. BuildContext

`BuildContext` 就是这个 widget 对应的 **Element**，也就是"我在树上的位置"。`Theme.of(context)` 的意思是从我这个位置往上找最近的 Theme。原理在 W3D4（InheritedWidget）讲。

## 4. 热重载到底做了什么 ⭐

**代码被替换 → 从根开始重新跑 `build` → State 对象保留。**

一句话：**热重载只会重跑 `build`，不会重跑"初始化"**。

| 改动 | 按 `r` 热重载 | 原因 |
|---|---|---|
| build 里的任何东西（间距、文字、颜色） | ✅ 生效 | build 会重跑 |
| 顶层或 static 变量的初始值（`final _tagline = ...`） | ❌ 不生效 | 懒初始化，只执行一次，早就初始化过了 |
| State 字段的初始值（`int _counter = 0`） | ❌ 不生效 | State 对象被保留 |
| `main()` 里的 `runApp(...)` | ❌ 不生效 | `main` 不会重跑 |
| 以上三种按 `R` 热重启 | ✅ 全部生效 | 整个程序重新开始，状态清零 |

常用按键（在 `flutter run` 的终端里）：`r` 热重载、`R` 热重启、`p` 显示布局边框、`o` 切换 Android/iOS 平台风格。

## 5. 字符串取首字：别用 `[0]`

和 Kotlin 一样，Dart 的 String 是 UTF-16，`'👍Tom'[0]` 只能取到半个 emoji。正确做法是按字素（grapheme）取：`name.characters.first`。`package:flutter/widgets.dart` 已经导出了 characters 包，可以直接用。Swift 的 `Character` 本来就按字素处理，所以 Swift 里没有这个坑。

## 6. 第一次见 widget test

```dart
await tester.pumpWidget(MaterialApp(home: Scaffold(body: child))); // 挂到测试树上，渲染一帧
expect(find.byType(Card), findsOneWidget);                          // 类似 Espresso 的 onView
tester.widgetList<Chip>(find.byType(Chip));                         // 按顺序取出 widget 检查属性
```

测试里套一层 `MaterialApp`，是为了给 Text、Card、Chip 提供主题和文字方向。第 5 周会细讲。

## 7. 参考答案

```dart
class Avatar extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim(); // 只 trim 一次
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
    return CircleAvatar(child: Text(initial));
  }
}

class InfoRow extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) =>
      Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]);
      // Icon(icon) 和 Text(label) 的参数是运行时值，不能 const
}

class ProfileCard extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(name: profile.name),
          Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
          Text(profile.title),
          InfoRow(icon: Icons.email, label: profile.email),
          if (profile.phone case final phone?) // if-case 绑定出非空值，不用写 !
            InfoRow(icon: Icons.phone, label: phone),
        ],
      ),
    ),
  );
}

class SkillChips extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const Text('暂无技能');
    final sorted = [...skills] // 先复制：不能修改父 widget 的数据，const 列表 sort 还会直接抛异常
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return Wrap(
      spacing: 8,
      children: [for (final skill in sorted) Chip(label: Text(skill))],
    );
  }
}
```

**类型提升规则补充**：只有**局部变量**和**私有 final 字段**能做类型提升。`profile.phone` 是另一个对象的公有字段，写了 `!= null` 判断之后仍然要加 `!`。解决办法有两个：用 `if (x case final v?)` 绑定，或者先赋给一个局部变量。

## 我犯过的错（review 记录）

**第一版只过了 8/13：交之前没跑测试。** 以后写完先自己跑 `flutter test`。

- Avatar：`''.characters.first` 抛 `Bad state: No element`。build 里抛异常，真机上就是一块红屏。注释里写了空名字要返回 `'?'`，我漏看了。
- ProfileCard：少了题目要求的 `Card` 和 `Padding`，直接返回了 Column。
- ProfileCard：`profile.phone!` 写了两次。原因是公有字段不能做类型提升，后来改成了 `if (profile.phone case final phone?)`。另外我自己加了 `isNotEmpty` 条件，题目里没有这个要求；加规则时应该在注释里说明。
- SkillChips：`sort()` 默认按 code unit 比较，大写字母会排在所有小写字母前面，结果出现 `Kotlin, dart` 这种顺序。需要传忽略大小写的比较器。
- SkillChips：漏了空列表时的占位文字。
- 做得好：`[...skills]` 先复制再排序，没有修改传入的列表（const 列表那条测试一次就过了）；InfoRow 里找对了能 const 的 `SizedBox`；改完后 Avatar 只 trim 一次，没有重复计算。
- 小问题（不影响结果）：`EdgeInsetsGeometry.all(16)` 一般直接写 `EdgeInsets.all(16)`；`...(list).map(...)` 改成 collection for 会更好读。

**热重载实验（猜对 3/4）**

- ❌ b：以为改了顶层变量 `_tagline` 的初始值，热重载后标题会变。实际不会变，因为顶层和 static 变量是懒初始化，只执行一次。
- ✅ c：State 字段 `_counter = 0` 改成 100，热重载后数字不变。
- ✅ d：改 `main()` 里的 `runApp`，热重载后界面不变。
- e：按 `R` 热重启后以上改动全部生效，计数器变成 100（State 重新创建了）。
