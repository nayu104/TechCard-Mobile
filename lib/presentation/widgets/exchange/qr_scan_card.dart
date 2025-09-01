import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers/providers.dart';

/// QRコードをスキャンして名刺交換を行うセクション。
/// MobileScannerで検出→最初の値を採用し、結果をトースト表示。
class QrScanCard extends ConsumerWidget {
  const QrScanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchange = ref.watch(exchangeServiceProvider);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 8),
            Text('QRコード交換')
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('QRコードをスキャン'),
            onPressed: () async {
              final nav = Navigator.of(context);
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: SizedBox(
                    width: 320,
                    height: 320,
                    child: MobileScanner(onDetect: (barcodes) async {
                      for (final bc in barcodes.barcodes) {
                        final raw = bc.rawValue;
                        if (raw == null) continue;
                        nav.pop();
                        final result = await exchange.exchangeByUserId(raw);
                        await Fluttertoast.showToast(msg: result.message);
                        if (result.added) {
                          ref.invalidate(contactsProvider);
                        }
                        break;
                      }
                    }),
                  ),
                ),
              );
            },
          )
        ]),
      ),
    );
  }
}
