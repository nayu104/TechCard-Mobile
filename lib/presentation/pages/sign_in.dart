import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

// テスト用シンプルログイン画面
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});
  static const route = '/sign-in';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サインイン'),
        // 左上の戻るボタン
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      //真ん中(Center)とした上で、縦(Column)にUIを配置
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TechCard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                try {
                  final login = ref.read(loginActionProvider);
                  await login();
                  // authStateProviderは自動的に更新されるため、手動での無効化は不要
                } catch (e) {
                  print('ログインエラー: $e');
                  // エラー表示を追加
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ログインに失敗しました: $e')),
                    );
                  }
                }
              },
              child: const Text('ゲストでログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
