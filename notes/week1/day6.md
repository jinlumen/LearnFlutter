# 第一周 Day 6：复盘（小测验 + 命令行记账）

日期：2026-11-01　练习：[dart_basics/day6.dart](../../dart_basics/day6.dart)

## 1. 小测验（6.5 / 8）

### Q1 初始化列表 ⚠️

final 字段有三个地方可以赋值：**声明处**、**初始化形参 `this.x`**、**初始化列表**。

初始化列表里**访问不到正在初始化的字段**，写 `name` 指的是参数，不是 `this.name`。所以如果想「先 trim 一次，再基于结果算别的字段」，要用**重定向构造函数**：

```dart
class User {
  final String name;
  final String id;
  User(String name) : this._(name.trim());       // 只 trim 一次
  User._(this.name) : id = name.toLowerCase();   // 这里的 name 已经 trim 过了
}
```

对照原生：Kotlin 是 `constructor(name: String) : this(name.trim())`，Swift 是 convenience init 委托给 designated init。

### Q2 事件循环 ✅

```dart
print('A');
Future(() => print('B'));
Future.value(1).then((_) => print('C'));
scheduleMicrotask(() => print('D'));
() async { print('E'); await null; print('F'); }();
print('G');
```

输出是 `A E G C D F B`：同步代码先打出 `A E G`；microtask 按入队顺序执行，依次是 `C`（`.then`）、`D`、`F`（await 的续体）；最后才是 event 队列里的 `B`。

### Q3 const ⚠️

```dart
const a = [1, 2];
final b = const [1, 2];
a.add(3);                 // 运行时抛 UnsupportedError；静态类型是 List<int>，所以编译能过
identical(a, b);          // true
```

结果是 `true`，原因是 **const 规范化**：值相同的 const 对象，整个程序只有一份实例。原因**不是**「它们都不可变」，反例：

```dart
identical(List.unmodifiable([1, 2]), List.unmodifiable([1, 2])) // false
```

### Q4 字段不提升 ✅

公开的、非 final 的字段可能被别的代码改掉，也可能被子类用 getter 覆盖，所以判空之后不会提升成非空类型。改法：

- 先拷到局部变量里：`final n = name;`
- 用 if-case：`if (name case final n?)`
- 用空安全操作符：`name?.length ?? 0`

### Q5 惰性 Iterable ❌

```dart
final it = [1, 2, 3].map((x) { print('map $x'); return x * 2; });
it.length;  // 不会执行 f！MappedListIterable 直接返回源 List 的长度
it.first;   // 执行 1 次
```

所以一共只打印 **1 次**。但如果换成 `where`，`.length` 就会把所有元素跑一遍，因为过滤后有几个元素，只有挨个跑过才知道。

结论：惰性 Iterable 会算多少次，取决于具体操作，没必要背。**要用多次就先 `.toList()`**。

### Q6 sealed ✅

用 sealed class 时，新增一个子类会让所有没覆盖它的 switch **编译报错**。换成 abstract class，switch 一开始就必须写 `_` 兜底，新增的子类会**悄悄落进兜底分支**，编译器不会提醒你。这比报错更危险。

### Q7 records ✅

`(1, name: 'a') == (1, name: 'a')` 是 `true`，`(1, 2) == (2, 1)` 是 `false`。records 可以当 Map 的 key，因为它的 `==` 和 `hashCode` 都按结构计算。

### Q8 异步异常 ✅

调用 `async` 函数时不 `await`，它抛出的异常就不会被外层的 try/catch 接住，会变成「未处理的异步错误」，直接让程序崩掉。要 `await boom();`，并且 main 也要改成 `async`。

## 2. 命令行记账：用到了什么

| 需求 | 用到的 Dart 特性 |
|---|---|
| 金额用「分」存成 int | 正则分组；`padRight` 补齐小数位；`~/` 和 `%` |
| 分类转小写、金额 > 0 | 初始化列表 + `assert` |
| 解析命令 | 一个 switch 表达式 + 列表模式 `['add', final a, final c, ...final rest]` |
| 执行命令 | sealed class + 对象模式 `Add(:final entry)`，穷尽检查 |
| 显示一条记录（备注可选） | null-aware 元素 `?entry.note`（Dart 3.8+） |
| 带序号的过滤 | `for (final (i, e) in list.indexed)` + collection if |
| 分类汇总 | `Map.update(..., ifAbsent:)`、record 排序（金额降序，同额按名字） |
| REPL | `stdin.transform(utf8.decoder).transform(LineSplitter())`，`await for` + `break` 会自动取消源 |

**可测试性**：`runRepl(Stream<String>, void Function(String))` 不直接依赖 stdin 和 print，测试时用 `StreamController` 喂数据，再用 `onCancel` 验证 quit 之后取消了源。这和原生里把 IO 注入进去、不写死依赖是同一个思路。

## 参考答案（review 后的写法）

```dart
final _amount = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');

int? parseCents(String s) {
  final match = _amount.firstMatch(s);
  if (match == null) return null;
  final fraction = (match[2] ?? '').padRight(2, '0');
  // 把整数部分和小数部分拼成一个「分」的整数，只 parse 一次，也避免了乘 100 溢出
  final cents = int.tryParse('${match[1]}$fraction');
  return cents != null && cents > 0 ? cents : null;
}

String formatCents(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

class Entry {
  final int cents;
  final String category;
  final String? note;

  Entry(this.cents, String category, [this.note])
    : assert(cents > 0),
      category = category.toLowerCase();
}

Command parse(String line) => switch (line
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .toList()) {
  [] || ['help'] => Help(),
  ['add', final amount, final category, ...final notes] =>
    _parseAdd(amount, category, notes),
  ['add', ...] => Invalid('用法：add <金额> <分类> [备注]'),
  ['list'] => ListEntries(),
  ['list', final category] => ListEntries(category.toLowerCase()),
  ['sum'] => Sum(),
  ['undo'] => Undo(),
  ['quit'] => Quit(),
  [final name, ...] => Invalid('未知命令：$name'),
};

class Ledger {
  final List<Entry> _entries = [];

  String execute(Command command) => switch (command) {
    Add(:final entry) => _add(entry),
    ListEntries(:final category) => _list(category),
    Sum() => _sum(),
    Undo() => _undo(),
    Help() => helpText,
    Quit() => '再见',
    Invalid(:final message) => '错误：$message',
  };

  String _formatEntry(int number, Entry entry) => [
    '#$number',
    entry.category,
    formatCents(entry.cents),
    ?entry.note,
  ].join(' ');

  String _list(String? category) {
    final lines = [
      for (final (i, e) in _entries.indexed)
        if (category == null || e.category == category) _formatEntry(i + 1, e),
    ];
    return lines.isEmpty ? '（没有记录）' : lines.join('\n');
  }

  String _undo() {
    if (_entries.isEmpty) return '没有可撤销的记录';
    final number = _entries.length;
    final entry = _entries.removeLast(); // 直接用返回值，不先读再删
    return '撤销 ${_formatEntry(number, entry)}';
  }
  // _add / _sum 见练习文件
}

Future<void> runRepl(Stream<String> lines, void Function(String) out) async {
  final ledger = Ledger();
  await for (final line in lines) {
    final command = parse(line);
    out(ledger.execute(command));
    if (command is Quit) break; // break 会取消对源 Stream 的订阅
  }
}
```

## 我犯过的错（review 记录）

**测验**
- Q1：在初始化列表里把 `name.trim()` 算了两遍。这是第 4 次出现「重复计算」。正解是用重定向构造函数。
- Q3：把 `identical` 为 true 的原因说成了「不可变」，实际原因是 const 规范化。
- Q5：以为 `map(...).length` 会执行映射函数，其实 List 的 map 结果知道自己的长度，不会执行。
- ✅ 进步：初始化列表（之前忘过两次）和 `.then` 进 microtask（Day 5 猜错过）这次都答对了。

**练习**（第一版就 54/54 通过，这周写得最干净的一份）
- 🐛 **用户输入超长金额会让程序崩溃**：`int.parse('99999999999999999999')` 抛 `FormatException`，整个 REPL 挂掉。测试和老师的参考答案也都漏了这个情况。原则：凡是用户输入，都不能让程序崩掉。修复：改用 `int.tryParse`，并把整数和小数部分拼成一个字符串只解析一次（这个写法比老师的更好），另外补了一条测试。
- `match[1] ?? ''`：整体匹配成功时第 1 组一定有值，写 `??` 反而掩盖了这个前提。
- 每次调用都新建 `RegExp`，后来提到了顶层变量，相当于把 `Pattern.compile` 放进 `companion object`。
- `totals[k] = (totals[k] ?? 0) + x` 查了两次 Map，后来改成了 `update(..., ifAbsent:)`。这是 Day 4 遗留的问题。
- 下标循环里 `_entries[i]` 取了两次，后来改成了 `.indexed` 加 records 解构。
- 做得好：初始化列表一次写对；`_sum` 一次循环同时算出小计和合计；`removeLast()` 直接用返回值；`parse` 先过滤空串，比参考答案更清楚；没有为了过测试写死的分支。
