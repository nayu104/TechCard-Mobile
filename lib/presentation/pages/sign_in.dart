import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../presentation/widgets/custom_text_field.dart';

// ===== ここから修正 =====
// テスト用シンプルログイン画面 → 名前入力付きログイン画面に変更
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  static const route = '/sign-in';

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

//メモリリーク防止：コントローラーを破棄（テキスト破棄）
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
// ===== ここまで修正 =====

  @override
  Widget build(BuildContext context) {
    // 認証状態を監視

    return Scaffold(
      appBar: AppBar(
        title: const Text('サインイン'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TechCard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              CustomTextField(
                labelText: 'ニックネーム',
                hintText: 'ニックネームを入力 (8文字まで)',
                controller: _nameController,
                maxLength: 8, // ← これで文字数制限が有効になる
              ),

              // TextField(
              //   controller: _nameController,
              //   maxLength: 8,
              //   decoration: const InputDecoration(
              //     labelText: 'ニックネーム',
              //     hintText: 'ニックネームを入力 (8文字まで)',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              const SizedBox(height: 16),
              // ===== ここまで追加 =====

              ElevatedButton(
                // ローディング or エラー表示
                onPressed: _isLoading ? null : _handleGuestLogin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('ゲストでログイン'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //エラー処理関数
  Future<void> _handleGuestLogin() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームを入力してください')),
      );
      return;
    }

    if (name.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームは8文字以内で入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final guestLogin = ref.read(guestLoginWithNameProvider);
      await guestLogin(name);
    } catch (e) {
      print('ログインエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // ===== ここまで追加 =====
}
