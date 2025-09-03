import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/qr_dialog.dart';
import '../gold_gradient_button.dart';

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
        child: OutlinedButton.icon(
          onPressed: () async {
            final handle = readHandle();
            await Clipboard.setData(ClipboardData(text: '@$handle'));
            await Fluttertoast.showToast(msg: 'コピーしました');
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('IDコピー'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GoldGradientButton(
          icon: Icons.qr_code_2,
          label: 'QRコード',
          onPressed: () {
            final id = readHandle();
            showDialog<void>(
              context: context,
              builder: (_) => QrDialog(data: id, caption: '@$id'),
            );
          },
        ),
      ),
    ]);
  }
}
