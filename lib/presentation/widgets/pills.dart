// 目的: ステータス表示用の簡易Pill。視認性重視、タップ不可のラベル用途。
import 'package:flutter/material.dart';



class DevPill extends StatelessWidget {
  const DevPill({super.key});

  @override

  /// 開発中ラベルのPillを描画。
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('開発中',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.label});
  final String label;

  @override

  /// スキルを示すChipを描画。ダーク/ライトで配色調整。
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFF176), // yellow 300
            Color(0xFFFFA000), // amber 700
            Color(0xFFF4511E), // deep orange 600
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: isDark ? Colors.black : Colors.black87, fontSize: 12)),
    );
  }
}

// Color.fromARGB(95, 64, 163, 255),
//Color.fromARGB(255, 82, 220, 255)
