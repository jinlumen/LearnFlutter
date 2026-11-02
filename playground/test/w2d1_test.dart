import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playground/w2d1.dart';

// 第二周 Day 1 的测试，不用改。
// 在 playground/ 下运行：flutter test test/w2d1_test.dart
// 这是你第一次见 widget test，第 5 周会细讲，今天看懂个大概就行：
//   pumpWidget  —— 把 widget 挂到一棵测试用的树上并渲染一帧
//   find.xxx    —— 在树里找 widget（类似 Espresso 的 onView / XCUITest 的 query）
//   expect      —— 断言

/// 测试里统一套一层 MaterialApp + Scaffold，给 Text/Card/Chip 提供主题和方向。
Future<void> pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  group('练习 1 Avatar', () {
    for (final (name, expected) in [
      ('alice', 'A'),
      ('  bob ', 'B'),
      ('曹操', '曹'),
      ('👍Tom', '👍'),
      ('', '?'),
      ('   ', '?'),
    ]) {
      testWidgets('"$name" → $expected', (tester) async {
        await pump(tester, Avatar(name: name));
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(CircleAvatar),
            matching: find.text(expected),
          ),
          findsOneWidget,
        );
      });
    }
  });

  group('练习 2 InfoRow', () {
    testWidgets('图标 + 间距 + 文字', (tester) async {
      await pump(tester, const InfoRow(icon: Icons.email, label: 'a@b.c'));
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children, hasLength(3));
      expect((row.children[0] as Icon).icon, Icons.email);
      expect((row.children[1] as SizedBox).width, 8);
      expect((row.children[2] as Text).data, 'a@b.c');
    });
  });

  group('练习 3 ProfileCard', () {
    const noPhone = Profile(name: 'Alice', title: '工程师', email: 'a@b.c');
    const withPhone = Profile(
      name: 'Bob',
      title: '设计师',
      email: 'b@b.c',
      phone: '123',
    );

    testWidgets('没有 phone 只有一行 InfoRow', (tester) async {
      await pump(tester, const ProfileCard(profile: noPhone));
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Avatar), findsOneWidget);
      expect(find.text('工程师'), findsOneWidget);
      expect(find.byType(InfoRow), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsNothing);
    });

    testWidgets('有 phone 两行 InfoRow，顺序 email 在前', (tester) async {
      await pump(tester, const ProfileCard(profile: withPhone));
      final rows = tester.widgetList<InfoRow>(find.byType(InfoRow)).toList();
      expect(rows.map((r) => r.icon), [Icons.email, Icons.phone]);
      expect(rows.map((r) => r.label), ['b@b.c', '123']);
    });

    testWidgets('名字用主题的 titleLarge', (tester) async {
      await pump(tester, const ProfileCard(profile: noPhone));
      final theme = Theme.of(tester.element(find.byType(ProfileCard)));
      final nameText = tester.widget<Text>(find.text('Alice'));
      expect(nameText.style, theme.textTheme.titleLarge);
    });
  });

  group('练习 4 SkillChips', () {
    List<String?> chipLabels(WidgetTester tester) => tester
        .widgetList<Chip>(find.byType(Chip))
        .map((c) => (c.label as Text).data)
        .toList();

    testWidgets('忽略大小写按字母序', (tester) async {
      await pump(tester, const SkillChips(skills: ['swift', 'Kotlin', 'dart']));
      expect(chipLabels(tester), ['dart', 'Kotlin', 'swift']);
      expect(tester.widget<Wrap>(find.byType(Wrap)).spacing, 8);
    });

    testWidgets('不修改传入的列表', (tester) async {
      final skills = ['b', 'a', 'c'];
      await pump(tester, SkillChips(skills: skills));
      expect(chipLabels(tester), ['a', 'b', 'c']);
      expect(skills, ['b', 'a', 'c']);
    });

    testWidgets('空列表显示占位文字', (tester) async {
      await pump(tester, const SkillChips(skills: []));
      expect(find.text('暂无技能'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });
  });
}
