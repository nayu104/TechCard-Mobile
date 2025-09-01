import 'package:flutter/material.dart';

/// テーマモードを選択するドロップダウン。
/// valueに現在値、onChangedで反映先を受け取る。
class ThemeSelector extends StatelessWidget {
  const ThemeSelector(
      {super.key, required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('ダークモード'),
      const Spacer(),
      DropdownButton<ThemeMode>(
        value: value,
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('端末設定')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('ライト')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('ダーク')),
        ],
        onChanged: onChanged,
      ),
    ]);
  }
}
