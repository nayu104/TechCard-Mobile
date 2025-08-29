import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/providers.dart';
import '../gold_gradient_button.dart';

class ExchangeForm extends ConsumerWidget {
  const ExchangeForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchange = ref.watch(exchangeServiceProvider);
    final controller = TextEditingController();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: const [
        Icon(Icons.search),
        SizedBox(width: 8),
        Text('ユーザーID検索')
      ]),
      const SizedBox(height: 12),
      TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'ユーザーID入力（例: demo）')),
      const SizedBox(height: 12),
      GoldGradientButton(
        icon: Icons.person_add_alt_1,
        label: '名刺交換する',
        onPressed: () async {
          final result =
              await exchange.exchangeByUserId(controller.text.trim());
          await Fluttertoast.showToast(msg: result.message);
          if (result.added) ref.invalidate(contactsProvider);
        },
      ),
    ]);
  }
}
