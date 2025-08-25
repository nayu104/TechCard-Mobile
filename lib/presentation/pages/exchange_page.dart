// 目的: 名刺交換画面。ユーザーID入力交換＋QRスキャン交換＋β/開発ピル表示。
// watch方針: サービスはread/イベント駆動、UIは最小限のwatch。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/global_providers.dart';
import '../widgets/gold_gradient_button.dart';
import '../widgets/pills.dart';

class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});
  @override
  ConsumerState<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage> {
  final controller = TextEditingController();
  @override

  /// ユーザーID交換/QRスキャン交換のUIを構築し、交換処理を呼び出す。
  Widget build(BuildContext context) {
    final exchange = ref.watch(exchangeServiceProvider);
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Text('ユーザーID検索')
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: 'ユーザーID入力（例: demo）')),
                    const SizedBox(height: 12),
                    // レイアウト意図: 主要CTAを視認性の高いゴールドグラデで強調。
                    GoldGradientButton(
                      icon: Icons.person_add_alt_1,
                      label: '名刺交換する',
                      onPressed: () async {
                        final result = await exchange
                            .exchangeByUserId(controller.text.trim());
                        await Fluttertoast.showToast(msg: result.message);
                        if (result.added) ref.invalidate(contactsProvider);
                      },
                    ),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  final result =
                                      await exchange.exchangeByUserId(raw);
                                  await Fluttertoast.showToast(
                                      msg: result.message);
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
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('近くのユーザー'),
                  DevPill(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.6,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Bluetooth検索'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Bluetoothを使って近くのユーザーと名刺交換'),
          )
        ],
      ),
    );
  }
}
