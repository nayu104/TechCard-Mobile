import 'package:flutter/material.dart';

/// テーマモードをスイッチで切り替える（ライト/ダークのみ）。
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key, required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = value == ThemeMode.dark;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.nights_stay_outlined),
      title: const Text('ダークモード'),
      subtitle: Text(isDark ? 'ダークテーマを使用中' : 'ライトテーマを使用中'),
      value: isDark,
      onChanged: (on) => onChanged(on ? ThemeMode.dark : ThemeMode.light),
    );
  }
}
