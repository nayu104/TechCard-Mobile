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
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('QRコードをスキャン'),
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
                          print('QRスキャン: 生データ=$raw');
                          print('QRスキャン: データ型=${raw.runtimeType}');
                          print('QRスキャン: データ長=${raw?.length ?? 0}');

                          if (raw == null || raw.trim().isEmpty) {
                            print('QRスキャン: 空のデータ');
                            continue;
                          }

                          // @マークや不可視文字の除去など、入力を正規化
                          final cleanData =
                              raw.startsWith('@') ? raw.substring(1) : raw;
                          final normalized = normalizeUserId(cleanData);
                          print('QRスキャン: 処理後データ(clean)=$cleanData');
                          print('QRスキャン: 正規化データ(normalized)=$normalized');
                          print('QRスキャン: 正規化データ長=${normalized.length}');

                          if (normalized.trim().isEmpty) {
                            print('QRスキャン: 無効なデータ');
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
          )
        ]),
      ),
    );
  }

  /// QRデータを処理して適切な検索を実行
  Future<void> _handleQrData(
      BuildContext context, WidgetRef ref, String data) async {
    try {
      print('QRスキャン: データ処理開始: $data');
      print('QRスキャン: データ長: ${data.length}');

      // 1. ユーザーIDとして検索を試行
      final isValidId = isValidUserId(data);
      print('QRスキャン: isValidUserId($data) = $isValidId');

      if (isValidId) {
        print('QRスキャン: ユーザーIDとして検索: $data');
        showDialog<void>(
          context: context,
          builder: (context) => UserSearchResultDialog(userId: data),
        );
        return;
      }

      // 2. GitHub URLかどうかを判定
      final hasGithubUrl = data.contains('github.com/');
      print('QRスキャン: GitHub URL含む: $hasGithubUrl');

      if (hasGithubUrl) {
        final githubUsername = _extractGithubUsername(data);
        print('QRスキャン: 抽出されたGitHub名: $githubUsername');

        if (githubUsername.isNotEmpty) {
          print('QRスキャン: GitHub名として検索: $githubUsername');
          await _searchByGithub(context, ref, githubUsername);
          return;
        }
      }

      // 3. 直接GitHub名として検索を試行
      print('QRスキャン: 直接GitHub名として検索: $data');
      await _searchByGithub(context, ref, data);
    } catch (e) {
      print('QRスキャン: エラー: $e');
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
        print('QRスキャン: GitHub名でユーザーが見つかりました: $githubUsername');
        showDialog<void>(
          context: context,
          builder: (context) => UserSearchResultDialog(userId: contact.userId),
        );
      } else {
        print('QRスキャン: GitHub名でユーザーが見つかりませんでした: $githubUsername');
        await Fluttertoast.showToast(msg: 'ユーザーが見つかりませんでした');
      }
    } catch (e) {
      print('QRスキャン: GitHub名検索エラー: $e');
      await Fluttertoast.showToast(msg: '検索に失敗しました: $e');
    }
  }
}
