import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import 'pages/contacts_page.dart';
import 'pages/exchange_page.dart';
import 'pages/my_card_page.dart';
import 'pages/settings_page.dart';
import 'pages/sign_in.dart';
import 'providers/providers.dart';

/// アプリのシェル。ボトムナビゲーションとタブごとのページ（IndexedStack）を束ねる。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  // // 端末の軽いバイブ例（必要なら有効化）
  // void vibrate() => HapticFeedback.lightImpact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final authState = ref.watch(authStateProvider);

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
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: RiveAnimation.asset(
                  'assets/title.riv',
                  fit: BoxFit.contain,
                  animations: const ['Animation 1'],
                ),
              ),
            ),
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
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFFFF8F00), // 橙（ダークでも視認性高）
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
            selectedIconTheme: const IconThemeData(color: Color(0xFFFF8F00)),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            ref.read(bottomNavProvider.notifier).state = value;
            // vibrate();
          },
          items: [
            BottomNavigationBarItem(
              icon: _NavIcon(
                key: const ValueKey('nav-0'),
                icon: currentIndex == 0
                    ? Icons.credit_card
                    : Icons.credit_card_outlined,
                selected: currentIndex == 0,
              ),
              label: '名刺',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                key: const ValueKey('nav-1'),
                icon: currentIndex == 1
                    ? Icons.view_list
                    : Icons.view_list_outlined,
                selected: currentIndex == 1,
              ),
              label: '一覧',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                key: const ValueKey('nav-2'),
                icon: currentIndex == 2
                    ? Icons.qr_code_2
                    : Icons.qr_code_2_outlined,
                selected: currentIndex == 2,
              ),
              label: '交換',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                key: const ValueKey('nav-3'),
                icon: Icons.settings_outlined,
                selected: false,
              ),
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
              SizedBox(
                width: 80,
                height: 80,
                child: RiveAnimation.asset(
                  'assets/title.riv',
                  fit: BoxFit.contain,
                  animations: const ['Animation 1'],
                ),
              ),
              const SizedBox(width: 0),
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 22,
          height: 22,
          child: RiveAnimation.asset(
            'assets/title.riv',
            fit: BoxFit.contain,
            animations: const ['Animation 1'],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RiveIcon extends StatefulWidget {
  const _RiveIcon({required this.size});
  final double size;

  @override
  State<_RiveIcon> createState() => _RiveIconState();
}

class _RiveIconState extends State<_RiveIcon> {
  Artboard? _artboard;
  static bool _riveInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  Future<void> _loadRive() async {
    try {
      if (!_riveInitialized) {
        await RiveFile.initialize();
        _riveInitialized = true;
      }
      final data = await rootBundle.load('assets/my.riv');
      final file = RiveFile.import(data);
      final board = file.mainArtboard;
      if (mounted) {
        setState(() => _artboard = board);
      }
    } catch (_) {
      // noop: 表示は空で続行
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const SizedBox.shrink(),
      );
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Rive(artboard: _artboard!, fit: BoxFit.contain),
    );
  }
}

// _RiveAsset は RiveAnimation.asset に置き換えました

/// シンプルなタブアイコンのアニメーション（フラッシュ無効・タップ感はスケール）
class _NavIcon extends StatelessWidget {
  const _NavIcon({super.key, required this.icon, required this.selected});
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // 設定アイコンだけ一回転の演出を加える
    final isCog = icon == Icons.settings || icon == Icons.settings_outlined;
    final rotationTurns = selected && isCog ? 1.0 : 0.0;

    return AnimatedRotation(
      duration: isCog
          ? const Duration(milliseconds: 380)
          : const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      turns: rotationTurns,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: selected ? 1.12 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: selected ? 1.0 : 0.85,
          child: Icon(icon),
        ),
      ),
    );
  }
}
