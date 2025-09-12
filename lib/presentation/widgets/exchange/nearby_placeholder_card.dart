import 'package:flutter/material.dart';
import '../pills.dart';

/// 近接交換（将来のBLE/NFC）のプレースホルダUI。
/// 実装時はこのカードを差し替える。
class NearbyPlaceholderCard extends StatelessWidget {
  const NearbyPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
          label: const Text(
            'Bluetooth検索',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Bluetoothを使って近くのユーザーと名刺交換'),
      )
    ]);
  }
}
