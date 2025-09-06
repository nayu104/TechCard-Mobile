import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:characters/characters.dart';

import '../providers/auth_providers.dart';
import '../widgets/custom_text_field.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  static const route = '/sign-in';

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final t = _nameController.text.trim();
      final ok = t.isNotEmpty && t.characters.length <= 15; // 1〜15文字
      if (ok != _canSubmit) {
        setState(() => _canSubmit = ok);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サインイン'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'TechCard',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // ★ CustomTextField の引数は “名前付き” で、カンマ/カッコを揃える
                  CustomTextField(
                    labelText: 'ニックネーム',
                    hintText: 'ニックネームを入力 (15文字まで)',
                    controller: _nameController,
                    maxLength: 15, // カウンタ表示
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15), // 実入力の物理制限
                    ],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleGuestLogin(),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      // ★ onPressed と child は “名前付き引数”。位置引数にしない
                      onPressed:
                          (_isLoading || !_canSubmit) ? null : _handleGuestLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('ゲストでログイン'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGuestLogin() async {
    final name = _nameController.text.trim();

    if (name.isEmpty || name.characters.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームは1〜15文字で入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final guestLogin = ref.read(guestLoginWithNameProvider);
      await guestLogin(name);

      if (!mounted) return;
      Navigator.of(context).pop(); // 必要なら前画面へ戻す
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
