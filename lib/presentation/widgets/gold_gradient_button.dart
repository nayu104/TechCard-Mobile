// 目的: 主要CTAを強調するゴールド系グラデボタン。可タップ領域48pxでアクセシビリティ配慮。
import 'package:flutter/material.dart';

class GoldGradientButton extends StatelessWidget {
  const GoldGradientButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.enabled = true,
      this.gradient});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final Gradient? gradient;

  @override

  /// ゴールドグラデの主要ボタンを構築。enabled=false時は非活性表示。
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final child = Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color.fromARGB(36, 64, 163, 255),
                    const Color.fromARGB(255, 64, 163, 255),
                  ]
                : [
                    const Color.fromARGB(101, 64, 93, 255),
                    const Color.fromARGB(255, 64, 163, 255),
                  ]),
        color: enabled
            ? null
            : Theme.of(context).disabledColor.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            if (icon != null) const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onPressed : null,
        child: child,
      ),
    );
  }
}
