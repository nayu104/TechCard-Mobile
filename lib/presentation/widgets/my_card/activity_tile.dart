import 'package:flutter/material.dart';

/// 活動項目を1行で表示。
class ActivityTile extends StatelessWidget {
  const ActivityTile(this.text, this.time, {super.key});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 10,
          height: 10,
          decoration:
              const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
      title: Text(text),
      trailing:
          Text(time, style: TextStyle(color: Theme.of(context).hintColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
