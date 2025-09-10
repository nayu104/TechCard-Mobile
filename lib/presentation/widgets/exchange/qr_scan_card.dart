import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../domain/models.dart';
import '../../providers/providers.dart';
import 'user_preview_dialog.dart';

/// QRコードをスキャンして名刺交換を行うセクション。
/// MobileScannerで検出→最初の値を採用し、結果をトースト表示。
class QrScanCard extends ConsumerWidget {
  const QrScanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 8),
            Text('QRコード交換')
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _GradientOutlinePillButton(
              icon: Icons.qr_code_scanner,
              label: 'QRコードをスキャン',
              onPressed: () async {
                final nav = Navigator.of(context);
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('QRコードをスキャン'),
                    content: SizedBox(
                      width: 320,
                      height: 320,
                      child: MobileScanner(
                        onDetect: (barcodes) async {
                          for (final bc in barcodes.barcodes) {
                            final raw = bc.rawValue;
                            // Debug logging removed for production
                            // Debug logging removed for production
                            // Debug logging removed for production

                            if (raw == null || raw.trim().isEmpty) {
                              // Debug logging removed for production
                              continue;
                            }

                            // @マークや不可視文字の除去など、入力を正規化
                            final cleanData =
                                raw.startsWith('@') ? raw.substring(1) : raw;
                            final normalized = normalizeUserId(cleanData);
                            // Debug logging removed for production
                            // Debug logging removed for production
                            // Debug logging removed for production

                            if (normalized.trim().isEmpty) {
                              // Debug logging removed for production
                              await Fluttertoast.showToast(msg: '無効なQRコードです');
                              continue;
                            }

                            nav.pop();

                            // データの形式を判定して適切な検索を実行
                            await _handleQrData(context, ref, normalized);
                            break;
                          }
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => nav.pop(),
                        child: const Text('キャンセル'),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  /// QRデータを処理して適切な検索を実行
  Future<void> _handleQrData(
      BuildContext context, WidgetRef ref, String data) async {
    try {
      // Debug logging removed for production
      // Debug logging removed for production

      // 1. ユーザーIDとして検索を試行
      final isValidId = isValidUserId(data);
      // Debug logging removed for production

      if (isValidId) {
        // Debug logging removed for production
        showDialog<void>(
          context: context,
          builder: (context) => UserSearchResultDialog(userId: data),
        );
        return;
      }

      // 2. GitHub URLかどうかを判定
      final hasGithubUrl = data.contains('github.com/');
      // Debug logging removed for production

      if (hasGithubUrl) {
        final githubUsername = _extractGithubUsername(data);
        // Debug logging removed for production

        if (githubUsername.isNotEmpty) {
          // Debug logging removed for production
          await _searchByGithub(context, ref, githubUsername);
          return;
        }
      }

      // 3. 直接GitHub名として検索を試行
      // Debug logging removed for production
      await _searchByGithub(context, ref, data);
    } catch (e) {
      // Debug logging removed for production
      await Fluttertoast.showToast(msg: 'QRコードの処理に失敗しました: $e');
    }
  }

  /// GitHub URLからユーザー名を抽出
  String _extractGithubUsername(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return '';

      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.first;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// GitHub名で検索を実行
  Future<void> _searchByGithub(
      BuildContext context, WidgetRef ref, String githubUsername) async {
    try {
      final remote = ref.read(remoteDirectoryRepositoryProvider);
      final contact = await remote.fetchByGithubUsername(githubUsername);

      if (contact != null) {
        // Debug logging removed for production
        showDialog<void>(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => UserSearchResultDialog(userId: contact.userId),
        );
      } else {
        // Debug logging removed for production
        await Fluttertoast.showToast(msg: 'ユーザーが見つかりませんでした');
      }
    } catch (e) {
      // Debug logging removed for production
      await Fluttertoast.showToast(msg: '検索に失敗しました: $e');
    }
  }
}

class _GradientOutlinePillButton extends StatelessWidget {
  const _GradientOutlinePillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // ダーク時は白、ライト時は黒
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final radius = BorderRadius.circular(24);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFF176), // yellow 300
            Color(0xFFFFA000), // amber 700
            Color(0xFFE53935), // red 600
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(1.5), // 枠線の太さ
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
