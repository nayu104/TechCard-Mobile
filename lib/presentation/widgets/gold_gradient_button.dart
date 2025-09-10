// 目的: 主要CTAを強調するゴールド系グラデボタン。可タップ領域48pxでアクセシビリティ配慮。
import 'package:flutter/material.dart';

class GoldGradientButton extends StatelessWidget {
  const GoldGradientButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.enabled = true,
      this.gradient,
      this.textColor});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final Gradient? gradient;
  final Color? textColor;

  @override

  /// ゴールドグラデの主要ボタンを構築。enabled=false時は非活性表示。
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final child = Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient ?? const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFFFCC80), // orange 200 (soft cream)
            Color(0xFFFF8F00), // amber 800 (rich orange)
            Color(0xFFF4511E), // deep orange 400
          ],
          stops: <double>[0.0, 0.6, 1.0],
        ),
        color: enabled
            ? null
            : Theme.of(context).disabledColor.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: textColor ?? Colors.black),
            if (icon != null) const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: textColor ?? Colors.black,
                    fontWeight: FontWeight.bold)),
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
