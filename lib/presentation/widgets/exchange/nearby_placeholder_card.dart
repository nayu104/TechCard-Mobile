import 'package:flutter/material.dart';
import '../pills.dart';

class NearbyPlaceholderCard extends StatelessWidget {
  const NearbyPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    ]);
  }
}
