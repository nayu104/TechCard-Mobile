import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDialog extends StatelessWidget {
  const QrDialog({super.key, required this.data, this.caption});
  final String data;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    // データが空の場合はエラー表示
    if (data.trim().isEmpty) {
      print('QRコード生成エラー: データが空です');
      return AlertDialog(
        title: const Text('QRコード'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text('ユーザーIDが設定されていません'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      );
    }

    // @マークを付けてユーザーID形式にする
    final qrData = data.startsWith('@') ? data : '@$data';

    print('QRコード生成: $qrData');

    return AlertDialog(
      title: const Text('QRコード'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: QrImageView(
              data: qrData,
              size: 220,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorStateBuilder: (context, error) {
                print('QRコード生成エラー: $error');
                return Container(
                  width: 220,
                  height: 220,
                  color: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'QRコード生成エラー',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        qrData,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (caption != null)
          Text(
            caption!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 8),
        Text(
          qrData,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
