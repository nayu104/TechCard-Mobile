import 'package:flutter/material.dart';
/*
/// 名刺が0件のときのプレースホルダ。交換画面への誘導ボタンを持つ。
class ContactsEmptyState extends StatelessWidget {
  const ContactsEmptyState({
    super.key,
    required this.onTapExchange,
    this.isLoading = false,
  });
  final VoidCallback onTapExchange;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (isLoading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('名刺を読み込み中...'),
        ] else ...[
          Image.asset('assets/ui_image/no_card.png', width: 180),
          const SizedBox(height: 8),
          const Text('まだ名刺がありません'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onTapExchange, child: const Text('名刺を交換する')),
        ],
      ]),
    );
  }
}
*/

class ContactsEmptyState extends StatelessWidget {
  final VoidCallback onTapExchange; //名刺を交換
  final VoidCallback? onTapSeedDemo; //でも名刺交換

  const ContactsEmptyState({
    super.key,
    required this.onTapExchange,
    this.onTapSeedDemo,
  });

  @override
  //UI　どのように描画するか
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/ui_image/no_card.png',
              width: 180), // アイコンをアセットに変更
          const SizedBox(height: 12),
          const Text('まだ名刺がありません'),
          const SizedBox(height: 16),
          ElevatedButton(
            //メインボタン
            onPressed: onTapExchange,
            child: const Text('名刺を交換する'),
          ),
          //開発時だけのボタン
          if (onTapSeedDemo != null) ...[
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
