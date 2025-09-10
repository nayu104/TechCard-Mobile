

import 'package:flutter/material.dart';
/*
/// 名刺が0件のときのプレースホルダ。交換画面への誘導ボタンを持つ。
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
*/

class ContactsEmptyState extends StatelessWidget{
  final VoidCallback onTapExchange; //名刺を交換
  final VoidCallback? onTapSeedDemo; //でも名刺交換

  const ContactsEmptyState({
    super.key,
    required this.onTapExchange,
    this.onTapSeedDemo,
  });

  @override
  //UI　どのように描画するか
  Widget build(BuildContext context){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, size: 72), //アイコン
          const SizedBox(height: 12),
          const Text('まだ名刺がありません'),
          const SizedBox(height: 16),
          ElevatedButton(//メインボタン
            onPressed: onTapExchange,
            child: const Text('名刺を交換する'),
          ),
          //開発時だけのボタン
          if(onTapSeedDemo != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onTapSeedDemo,
              child: const Text('でも名刺を追加する'),
            ),
          ],
         ],
      ),
    );
  }
}