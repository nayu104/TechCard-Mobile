import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDialog extends StatelessWidget {
  const QrDialog({super.key, required this.data, this.caption});
  final String data;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: data.isEmpty ? 'demo' : data, size: 220),
        const SizedBox(height: 8),
        if (caption != null) Text(caption!),
      ]),
    );
  }
}
