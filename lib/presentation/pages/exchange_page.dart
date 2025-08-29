// 目的: 名刺交換画面。ユーザーID入力交換＋QRスキャン交換＋β/開発ピル表示。
// watch方針: サービスはread/イベント駆動、UIは最小限のwatch。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/pills.dart';
import '../widgets/exchange/exchange_form.dart';
import '../widgets/exchange/qr_scan_card.dart';
import '../widgets/exchange/nearby_placeholder_card.dart';

class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});
  @override
  ConsumerState<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage> {
  @override

  /// ユーザーID交換/QRスキャン交換のUIを構築し、交換処理を呼び出す。
  Widget build(BuildContext context) {
    // Exchange form/scan widgets handle providers internally.
    return Scaffold(
      appBar: AppBar(title: const Text('名刺交換'), actions: const [
        Padding(padding: EdgeInsets.only(right: 12), child: BetaPill())
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const ExchangeForm(),
            ),
          ),
          const SizedBox(height: 12),
          const QrScanCard(),
          const SizedBox(height: 12),
          const NearbyPlaceholderCard(),
        ],
      ),
    );
  }
}
