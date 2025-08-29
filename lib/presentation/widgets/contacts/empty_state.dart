import 'package:flutter/material.dart';

class ContactsEmptyState extends StatelessWidget {
  const ContactsEmptyState({super.key, required this.onTapExchange});
  final VoidCallback onTapExchange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.contact_page_outlined, size: 64),
        const SizedBox(height: 8),
        const Text('まだ名刺がありません'),
        const SizedBox(height: 16),
        FilledButton(onPressed: onTapExchange, child: const Text('名刺を交換する')),
      ]),
    );
  }
}
