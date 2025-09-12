import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../widgets/custom_text_field.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  static const route = '/sign-in';

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _nameController = TextEditingController();
  var _isLoading = false;
  var _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final t = _nameController.text.trim();
      final ok = t.isNotEmpty && t.characters.length <= 8; // 1〜15文字
      if (ok != _canSubmit) {
        setState(() => _canSubmit = ok);
      }
    });
  }

  // メモリ開放
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/ui_image/tech_card_02.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),

                  // ★ CustomTextField の引数は “名前付き” で、カンマ/カッコを揃える
                  CustomTextField(
                    labelText: 'ニックネーム',
                    hintText: 'ニックネームを入力 (8文字まで)',
                    controller: _nameController,
                    maxLength: 8, // カウンタ表示
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8), // 実入力の物理制限
                    ],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleGuestLogin(),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Builder(builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final fg = isDark ? Colors.white : Colors.black;
                      return ElevatedButton(
                        onPressed: (_isLoading || !_canSubmit)
                            ? null
                            : _handleGuestLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: fg,
                          shape: const StadiumBorder(),
                          elevation: 0,
                          side:
                              const BorderSide(color: Colors.black, width: 1.2),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Image.asset(
                                  //   'assets/ui_image/login_icon.png',
                                  //   height: 30,
                                  //   fit: BoxFit.contain,
                                  // ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'はじめる',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: fg,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  const Text('または'),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                final login = ref.read(githubLoginProvider);
                                await login();
                                if (!mounted) return;
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              } catch (e) {
                                if (!mounted) return;
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('GitHubログインに失敗しました: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                      icon: Image.asset(
                        'assets/ui_image/github-mark-white.png',
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      label: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Githubでログイン',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                      //ボタンの見た目
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white, //文字色
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 14),
                        elevation: 0,
                      ),
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

    if (name.isEmpty || name.characters.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームは1〜8文字で入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final guestLogin = ref.read(guestLoginWithNameProvider);
      await guestLogin(name);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(); // 必要なら前画面へ戻す
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //Githubでログインする
}
