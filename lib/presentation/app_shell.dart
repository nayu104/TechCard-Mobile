import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import 'pages/contacts_page.dart';
import 'pages/exchange_page.dart';
import 'pages/my_card_page.dart';
import 'pages/settings_page.dart';
import 'pages/sign_in.dart';
import 'providers/providers.dart';

/// Rive のアニメーションを 24x24 のアイコンとして表示するウィジェット。
/// `play` が true のときだけ再生（選択中タブだけ動く）。
class RiveIcon extends StatefulWidget {
  const RiveIcon({
    super.key,
    required this.asset,
    required this.animationName,
    this.play = true,
  });

  final String asset; // 例: 'assets/pendulum.riv'
  final String animationName; // 例: 'Timeline 1'
  final bool play;

  @override
  State<RiveIcon> createState() => _RiveIconState();
}

class _RiveIconState extends State<RiveIcon> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation(widget.animationName, autoplay: widget.play);
  }

  @override
  void didUpdateWidget(covariant RiveIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 再生/停止を切り替え（選択状態によって変化）
    if (_controller.isActive != widget.play) {
      _controller.isActive = widget.play;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: RiveAnimation.asset(
        widget.asset,
        controllers: [_controller],
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

/// アプリのシェル。ボトムナビゲーションとタブごとのページ（IndexedStack）を束ねる。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  // // 端末の軽いバイブ例（必要なら有効化）
  // void vibrate() => HapticFeedback.lightImpact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final authState = ref.watch<AsyncValue<User?>>(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechCard'),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          authState.when(
            data: (user) {
              if (user == null) {
                // 未ログイン
                return Tooltip(
                  message: 'ログイン',
                  child: IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignInPage(),
                        ),
                      );
                    },
                  ),
                );
              } else {
                // ログイン済み時：ユーザー名表示
                return _buildWelcomeMessage(ref, user.uid);
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          MyCardPage(),
          ContactsPage(),
          ExchangePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
          splashFactory: NoSplash.splashFactory, // タップ時フラッシュ無効
          highlightColor: Colors.transparent, // ハイライト無効
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            ref.read(bottomNavProvider.notifier).state = value;
            // vibrate();
          },
          // Rive を使うので const は外す
          items: [
            BottomNavigationBarItem(
              icon: RiveIcon(
                asset: 'assets/badge.riv', // ← 修正！
                animationName: 'Timeline 1', // ← Rive 側のタイムライン名
                play: currentIndex == 0,
              ),
              activeIcon: RiveIcon(
                asset: 'assets/badge.riv', // ← 修正！
                animationName: 'Timeline 1',
                play: true,
              ),
              label: '名刺',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.view_list_outlined),
              activeIcon: Icon(Icons.view_list),
              label: '一覧',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_outlined),
              activeIcon: Icon(Icons.qr_code_2),
              label: '交換',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }

  // ログイン済み時のウェルカムメッセージ
  Widget _buildWelcomeMessage(WidgetRef ref, String uid) {
    final profileAsync = ref.watch(firebaseProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final userName = profile?.name ?? 'ゲスト';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
