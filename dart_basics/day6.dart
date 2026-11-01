import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 第一周 Day 6 复盘：命令行记账小程序
// 跑测试：dart run --enable-asserts dart_basics/day6.dart --test
// 手动玩：dart run --enable-asserts dart_basics/day6.dart
// 把 throw UnimplementedError() 换成你的实现。
// 这一周用到的东西今天全会用上：空安全、初始化列表、sealed + switch、
// 列表模式、records、collection for/if、Stream + await for。
// 老规矩：每个值只算一次、不为了过测试写死分支。
//
// 示例会话：
//   > add 12.5 food 午饭
//   #1 food 12.50 午饭
//   > add 3 Transport
//   #2 transport 3.00
//   > sum
//   food 12.50
//   transport 3.00
//   合计 15.50
//   > undo
//   撤销 #2 transport 3.00
//   > quit
//   再见

// ───────── 练习 1：金额 ─────────
// 金额统一用「分」存 int，别用 double（0.1 + 0.2 != 0.3，原生里你也是这么干的）。
// parseCents：'12.5' → 1250，'12.05' → 1205，'3' → 300。
// 以下都返回 null：'abc'、'-3'、'12.345'（最多两位小数）、'12.'、'.5'、'0'、'0.00'（必须 > 0）。
// 提示：一个正则 + 分组就够了，别 parse 两遍。

final _amount = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');
int? parseCents(String s) {
  final match = _amount.firstMatch(s);
  if (match == null) return null;

  final fraction = (match[2] ?? '').padRight(2, '0');
  // 直接解析以分为单位的整数，避免乘以 100 时溢出。
  final cents = int.tryParse('${match[1]}$fraction');
  return cents != null && cents > 0 ? cents : null;
}

// formatCents：1250 → '12.50'，5 → '0.05'，100000 → '1000.00'
String formatCents(int cents) {
  final dollar = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '$dollar.$fraction';
}

// ───────── 练习 2：Entry（初始化列表！）─────────
// 要求：
//   - 分类统一转小写存储（'Food' → 'food'）
//   - cents 必须 > 0，用 assert 检查（--enable-asserts 下 Entry(0, 'x') 要抛 AssertionError）
//   - 三个字段都保持 final，不许用 late
// 只改构造函数这一行（冒号后面），字段声明别动。
class Entry {
  final int cents;
  final String category;
  final String? note;

  Entry(this.cents, String category, [this.note])
    : assert(cents > 0),
      category = category.toLowerCase();
}

// ───────── 命令（已给出，不用改）─────────
sealed class Command {}

class Add extends Command {
  final Entry entry;
  Add(this.entry);
}

class ListEntries extends Command {
  final String? category; // null = 全部
  ListEntries([this.category]);
}

class Sum extends Command {}

class Undo extends Command {}

class Help extends Command {}

class Quit extends Command {}

class Invalid extends Command {
  final String message;
  Invalid(this.message);
}

const helpText = '''命令：
  add <金额> <分类> [备注]   记一笔
  list [分类]                列出记录
  sum                        按分类汇总
  undo                       撤销最后一笔
  help                       显示帮助
  quit                       退出''';

// ───────── 练习 3：解析 ─────────
// 把一行输入解析成 Command。单词之间可能有多个空格，首尾可能有空格。
//   ''、'   '、'help'          → Help()
//   'add 12.5 food'            → Add(Entry(1250, 'food'))
//   'add 12.5 Food 和 同事 吃饭' → Add(Entry(1250, 'food', '和 同事 吃饭'))  备注用单个空格拼回去
//   'add abc food'             → Invalid('金额无效：abc')
//   'add'、'add 12'            → Invalid('用法：add <金额> <分类> [备注]')
//   'list'                     → ListEntries()
//   'list Food'                → ListEntries('food')
//   'sum' / 'undo' / 'quit'    → 对应命令
//   'eat 3'                    → Invalid('未知命令：eat')
// 要求：用一个 switch 表达式 + 列表模式（[..., ...rest] 那种）完成，不要一串 if。
Command parse(String line) => switch (line
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .toList()) {
  [] || ['help'] => Help(),
  ['add', final amount, final category, ...final notes] => _parseAdd(
    amount,
    category,
    notes,
  ),
  ['add', ...] => Invalid('用法：add <金额> <分类> [备注]'),
  ['list'] => ListEntries(),
  ['list', final category] => ListEntries(category.toLowerCase()),
  ['sum'] => Sum(),
  ['undo'] => Undo(),
  ['quit'] => Quit(),
  [final name, ...] => Invalid('未知命令：$name'),
};

Command _parseAdd(String amount, String category, List<String> notes) {
  final cents = parseCents(amount);
  if (cents == null) return Invalid('金额无效：$amount');
  return Add(Entry(cents, category, notes.isEmpty ? null : notes.join(' ')));
}

// ───────── 练习 4：账本 ─────────
// execute 返回要打印的文本（不要在里面 print）。
// 一条记录显示为：'#序号 分类 金额 备注'，没有备注就不带结尾空格，序号从 1 开始。
//   Add          → 那条记录的显示，如 '#1 food 12.50 午饭'
//   ListEntries  → 每条一行（序号是它在全部记录中的序号，过滤后不重新编号）；
//                  没有匹配的记录 → '（没有记录）'
//   Sum          → 每个分类一行 '分类 金额'，按金额从大到小，金额相同按分类名字母序；
//                  最后一行 '合计 金额'；没有记录 → '（没有记录）'
//   Undo         → '撤销 ' + 被撤销那条的显示；没有记录 → '没有可撤销的记录'
//   Help         → helpText
//   Quit         → '再见'
//   Invalid      → '错误：' + message
// 要求：execute 用 switch 表达式 + 对象模式（Add(:final entry) 那种）。
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

  String _add(Entry entry) {
    _entries.add(entry);
    return _formatEntry(_entries.length, entry);
  }

  String _list(String? category) {
    final lines = [
      for (final (i, e) in _entries.indexed)
        if (category == null || e.category == category) _formatEntry(i + 1, e),
    ];
    return lines.isEmpty ? '（没有记录）' : lines.join('\n');
  }

  String _sum() {
    if (_entries.isEmpty) return '（没有记录）';

    final totals = <String, int>{};
    var total = 0;
    for (final entry in _entries) {
      totals.update(
        entry.category,
        (v) => v + entry.cents,
        ifAbsent: () => entry.cents,
      );
      total += entry.cents;
    }

    // 用 record 保存分类与小计，金额相同时再按分类名排序。
    final sorted =
        [
          for (final entry in totals.entries)
            (category: entry.key, cents: entry.value),
        ]..sort((a, b) {
          final byAmount = b.cents.compareTo(a.cents);
          return byAmount != 0 ? byAmount : a.category.compareTo(b.category);
        });

    return [
      for (final item in sorted) '${item.category} ${formatCents(item.cents)}',
      '合计 ${formatCents(total)}',
    ].join('\n');
  }

  String _undo() {
    if (_entries.isEmpty) return '没有可撤销的记录';
    final number = _entries.length;
    final entry = _entries.removeLast();
    return '撤销 ${_formatEntry(number, entry)}';
  }
}

// ───────── 练习 5：REPL ─────────
// 逐行读 lines，每行 parse → execute → out(结果)。
// 遇到 quit：输出 '再见' 后立刻停止，后面的行不再处理（也就不再读源）。
Future<void> runRepl(Stream<String> lines, void Function(String) out) async {
  final ledger = Ledger();
  await for (final line in lines) {
    final command = parse(line);
    out(ledger.execute(command));
    if (command is Quit) break;
  }
}

// ─────────────────────────────────────────────

Future<void> main(List<String> args) async {
  if (args.contains('--test')) return runTests();
  print(helpText);
  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await runRepl(lines, print);
}

Future<void> runTests() async {
  // ── 练习 1 ──
  check('parseCents 12.5', () => parseCents('12.5'), 1250);
  check('parseCents 12.05', () => parseCents('12.05'), 1205);
  check('parseCents 3', () => parseCents('3'), 300);
  check('parseCents 0.01', () => parseCents('0.01'), 1);
  check(
    'parseCents int 最大值',
    () => parseCents('92233720368547758.07'),
    9223372036854775807,
  );
  for (final bad in [
    'abc',
    '-3',
    '12.345',
    '12.',
    '.5',
    '0',
    '0.00',
    '',
    '1e3',
    '99999999999999999999',
    '92233720368547758.08',
    '184467440737095517',
  ]) {
    check('parseCents "$bad" 无效', () => parseCents(bad), null);
  }
  check('formatCents 1250', () => formatCents(1250), '12.50');
  check('formatCents 5', () => formatCents(5), '0.05');
  check('formatCents 100000', () => formatCents(100000), '1000.00');
  check('formatCents 1207', () => formatCents(1207), '12.07');

  // ── 练习 2 ──
  check('Entry 小写', () => Entry(100, 'FoOd').category, 'food');
  check('Entry note', () => Entry(100, 'food', '午饭').note, '午饭');
  check('Entry 无 note', () => Entry(100, 'food').note, null);
  check('Entry assert', () {
    try {
      Entry(0, 'food');
      return '没抛';
    } on AssertionError {
      return 'AssertionError';
    }
  }, 'AssertionError');

  // ── 练习 3 ──
  String show(Command c) => switch (c) {
    Add(:final entry) =>
      'Add(${entry.cents}, ${entry.category}, ${entry.note})',
    ListEntries(:final category) => 'List($category)',
    Invalid(:final message) => 'Invalid($message)',
    _ => c.runtimeType.toString(),
  };
  check('parse 空', () => show(parse('')), 'Help');
  check('parse 全空格', () => show(parse('   ')), 'Help');
  check('parse help', () => show(parse('help')), 'Help');
  check(
    'parse add',
    () => show(parse('add 12.5 food')),
    'Add(1250, food, null)',
  );
  check(
    'parse add 备注',
    () => show(parse('  add  12.5   Food 和  同事 吃饭 ')),
    'Add(1250, food, 和 同事 吃饭)',
  );
  check(
    'parse add 坏金额',
    () => show(parse('add abc food')),
    'Invalid(金额无效：abc)',
  );
  check(
    'parse add 缺参数',
    () => show(parse('add 12')),
    'Invalid(用法：add <金额> <分类> [备注])',
  );
  check(
    'parse add 无参数',
    () => show(parse('add')),
    'Invalid(用法：add <金额> <分类> [备注])',
  );
  check('parse list', () => show(parse('list')), 'List(null)');
  check('parse list 分类', () => show(parse('list Food')), 'List(food)');
  check('parse sum', () => show(parse('sum')), 'Sum');
  check('parse undo', () => show(parse('undo')), 'Undo');
  check('parse quit', () => show(parse('quit')), 'Quit');
  check('parse 未知', () => show(parse('eat 3')), 'Invalid(未知命令：eat)');

  // ── 练习 4 ──
  final ledger = Ledger();
  String run(String line) => ledger.execute(parse(line));
  check('空 list', () => run('list'), '（没有记录）');
  check('空 sum', () => run('sum'), '（没有记录）');
  check('空 undo', () => run('undo'), '没有可撤销的记录');
  check('add 1', () => run('add 12.5 food 午饭'), '#1 food 12.50 午饭');
  check('add 2', () => run('add 3 Transport'), '#2 transport 3.00');
  check('add 3', () => run('add 20 fun'), '#3 fun 20.00');
  check('add 4', () => run('add 7.5 Food 奶茶'), '#4 food 7.50 奶茶');
  check(
    'list 全部',
    () => run('list'),
    '#1 food 12.50 午饭\n#2 transport 3.00\n#3 fun 20.00\n#4 food 7.50 奶茶',
  );
  check('list 过滤', () => run('list food'), '#1 food 12.50 午饭\n#4 food 7.50 奶茶');
  check('list 无匹配', () => run('list rent'), '（没有记录）');
  check(
    'sum 同额按字母',
    () => run('sum'),
    'food 20.00\nfun 20.00\ntransport 3.00\n合计 43.00',
  );
  check('undo', () => run('undo'), '撤销 #4 food 7.50 奶茶');
  check(
    'sum 撤销后',
    () => run('sum'),
    'fun 20.00\nfood 12.50\ntransport 3.00\n合计 35.50',
  );
  check('add 撤销后序号', () => run('add 1 fun'), '#4 fun 1.00');
  check('invalid', () => run('eat'), '错误：未知命令：eat');
  check('help', () => run('help'), helpText);
  check('quit', () => run('quit'), '再见');

  // ── 练习 5 ──
  var cancelled = false;
  final source = StreamController<String>(onCancel: () => cancelled = true);
  final output = <String>[];
  final done = runRepl(source.stream, output.add);
  for (final line in ['add 5 food', 'sum', 'quit', 'add 99 never']) {
    source.add(line);
  }
  await check('REPL', () async {
    await done.timeout(const Duration(seconds: 1)); // 没在 quit 处停下就会超时
    return output.join(' | ');
  }, '#1 food 5.00 | food 5.00\n合计 5.00 | 再见');
  check('REPL quit 后取消了源', () => cancelled, true);
}

Future<void> check(
  String label,
  FutureOr<Object?> Function() actual,
  Object? expected,
) async {
  Object? value;
  try {
    value = await actual();
  } catch (e) {
    value = '抛出异常 $e';
  }
  final ok = value == expected;
  print('${ok ? '✅' : '❌'} $label${ok ? '' : '  期望 $expected，实际 $value'}');
}
