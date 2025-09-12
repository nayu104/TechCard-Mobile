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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFCC80), Color(0xFFFF8F00), Color(0xFFF4511E)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: onSurface, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// Color.fromARGB(95, 64, 163, 255),
//Color.fromARGB(255, 82, 220, 255)
