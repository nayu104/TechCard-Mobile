import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/qr_dialog.dart';
import '../gold_gradient_button.dart';
import '../../../domain/models.dart';

/// 名刺アクション群（IDコピー/QR表示）を横並びで提供する行。
/// - 左: ハンドル文字列をクリップボードへコピー
/// - 右: GoldGradientButtonでQRダイアログを開く
class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
    required this.handleText,
    required this.readHandle,
  });

  final String handleText;
  final String Function() readHandle;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _GradientOutlinePillButton(
          icon: Icons.copy_outlined,
          label: 'IDコピー',
          onPressed: () async {
            final handle = readHandle();
            // @や不可視文字を除去してコピー
            final cleanHandle = normalizeUserId(handle);
            await Clipboard.setData(ClipboardData(text: cleanHandle));
            await Fluttertoast.showToast(msg: 'コピーしました');
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GoldGradientButton(
          icon: Icons.qr_code_2,
          label: 'QRコード',
          textColor: Colors.black,
          onPressed: () {
            final id = readHandle();
            // @や不可視文字を除去してQRコード生成
            final cleanId = normalizeUserId(id);
            print('QRコード表示開始: ID=$cleanId');
            showDialog<void>(
              context: context,
              builder: (_) => QrDialog(data: cleanId, caption: '@$cleanId'),
            );
          },
        ),
      ),
    ]);
  }
}

class _GradientOutlinePillButton extends StatelessWidget {
  const _GradientOutlinePillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final radius = BorderRadius.circular(24);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFF176), // yellow 300
            Color(0xFFFFA000), // amber 700
            Color(0xFFE53935), // red 600
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(1.5), // 枠線の太さ
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
