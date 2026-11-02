import 'package:flutter/material.dart';

// 第二周 Day 1：一切皆 Widget
// 跑测试：在 playground/ 下 flutter test test/w2d1_test.dart
// 看效果：flutter run（main.dart 的 home 已经指向 W2D1Page），改完按 r 热重载
// 把每个 build 里的 throw UnimplementedError() 换成你的实现。
// 老规矩：每个值只算一次、不为了过测试写死分支。今天新加一条：build 必须是「纯」的。

// ───────── 练习 1：Avatar ─────────
// 圆形头像，里面显示名字的第一个字（大写）。
// 'alice' → 'A'，'  bob ' → 'B'，'曹操' → '曹'，'👍Tom' → '👍'，''/'   ' → '?'
// 用 CircleAvatar(child: Text(...))。
// 提示：String[0] 取的是 UTF-16 code unit，emoji 会被劈成半个。
//      Flutter 已经帮你导出了 characters 包：name.characters.first。
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final first = trimmed.isEmpty
        ? '?'
        : trimmed.characters.first.toUpperCase();
    return CircleAvatar(child: Text(first));
  }
}

// ───────── 练习 2：InfoRow ─────────
// 一行：图标 + 8 像素间距 + 文字。
// 用 Row(children: [Icon(icon), SizedBox(width: 8), Text(label)])。
// 想一想：哪几个子 widget 能加 const？
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) =>
      Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]);
}

// ───────── 练习 3：ProfileCard ─────────
// Card 里一个 Padding(16) 包着 Column（crossAxisAlignment: CrossAxisAlignment.start），从上到下：
//   Avatar(name)
//   Text(name)，样式用主题里的 titleLarge（Theme.of(context).textTheme.titleLarge）
//   Text(title)
//   InfoRow(Icons.email, email)
//   InfoRow(Icons.phone, phone) —— 只有 phone 不为 null 时才有这一行
// 提示：Day 4 学过的 collection if，不要 if/else 复制两份 children。
class Profile {
  const Profile({
    required this.name,
    required this.title,
    required this.email,
    this.phone,
  });

  final String name;
  final String title;
  final String email;
  final String? phone;
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(name: profile.name),
          Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
          Text(profile.title),
          InfoRow(icon: Icons.email, label: profile.email),
          if (profile.phone case final phone?)
            InfoRow(icon: Icons.phone, label: phone),
        ],
      ),
    ),
  );
}

// ───────── 练习 4：SkillChips ─────────
// 按字母序（忽略大小写）显示技能，每个技能一个 Chip(label: Text(skill))，
// 放进 Wrap(spacing: 8, children: [...])。
// skills 为空时只显示 Text('暂无技能')。
// ⚠️ 不许改动传进来的 skills —— 它是父 widget 的数据，build 可能被调用很多次。
class SkillChips extends StatelessWidget {
  const SkillChips({super.key, required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) => skills.isEmpty
      ? const Text('暂无技能')
      : Wrap(
          spacing: 8,
          children: [
            ...([...skills]
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))
                .map((skill) => Chip(label: Text(skill))),
          ],
        );
}

// ───────── 练习 5：热重载实验（先猜，再验证）─────────
// flutter run 起来以后，按顺序做下面的改动，每次改完按 r（热重载）。
// ⚠️ 每一条先把你的猜测写在「猜：」后面，再动手。猜错了别改猜测，在「实际：」里写真相
//    （和 Day 5 事件循环那次一样，错误的猜测最有复习价值）。
//
// a) 把 W2D1Page 里 ProfileCard 下面的 SizedBox(height: 16) 改成 64。
//    猜：技能栏往下移
//    实际：✔
// b) 把下面 _tagline 的值改成别的字符串。AppBar 标题会变吗？
//    猜：会变
//    实际：不变
// c) 打开 main.dart，把 MyApp 里的 home: const W2D1Page() 改成
//    home: const MyHomePage(title: 'counter')，热重载，点几次 + 让计数器变成非 0，
//    然后把 _MyHomePageState 里的 int _counter = 0 改成 = 100。数字会变成 100 吗？
//    猜：不变
//    实际：不变
// d) 还在计数器页，把 main() 里的 runApp(const MyApp()) 改成
//    runApp(const MaterialApp(home: W2D1Page()))。界面会切换吗？
//    猜：不变
//    实际：不变
// e) 把 b、c、d 里没生效的那几个，按 R（热重启）再看一次。计数器还剩多少？
//    实际：全变，计数器变为100
// 做完把 main.dart 改回 home: const W2D1Page()、runApp(const MyApp())。
//
// 附加观察：终端里每次热重载都会打印 'W2D1Page.build'，说明热重载会重新跑 build。

// ───────── 下面是给 flutter run 看效果用的页面 ─────────

final _tagline = '今天是第二周第一天。。';

class W2D1Page extends StatelessWidget {
  const W2D1Page({super.key});

  static const _me = Profile(
    name: 'caojinlong',
    title: 'Android / iOS → Flutter',
    email: 'me@example.com',
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('W2D1Page.build');
    return Scaffold(
      appBar: AppBar(title: Text(_tagline)),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCard(profile: _me),
            SizedBox(height: 64),
            SkillChips(skills: ['Kotlin', 'swift', 'Dart', 'compose']),
          ],
        ),
      ),
    );
  }
}
