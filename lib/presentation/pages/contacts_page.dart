// 目的: 名刺一覧画面。主要要素=リスト表示＋折りたたみ詳細＋βピル。
// watch方針: 一覧はwatchで再ビルド。詳細の展開状態はローカルStateで最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/contacts/contact_list_item.dart';
import '../widgets/contacts/empty_state.dart';
// ...existing code...

/// 名刺一覧ページ。
/// 0件時のプレースホルダと、展開可能な連絡先カードのリストを表示する。
class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final Map<String, bool> _expanded = {};
  var _showAll = false; // 全件表示フラグ

  /// 「もっと見る」ボタンを構築
  Widget _buildLoadMoreButton(int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _showAll = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.expand_more,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '残り${totalCount - 5}件を表示',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 名刺一覧を取得し、展開/折りたたみ可能なリストを描画する。
  @override
  Widget build(BuildContext context) {
    // Firebaseから名刺一覧を取得
    // getContactsメソッドを使用
    final contactsAsync = ref.watch(firebaseContactsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // Firebaseから差分取得（プロバイダーを無効化して再取得）
          ref.invalidate(firebaseContactsProvider);
          // プロバイダーの完了を待つ
          await ref.read(firebaseContactsProvider.future);
        },
        child: contactsAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('名刺を読み込み中...'),
              ],
            ),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '読み込みに失敗しました',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'エラー: $e',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(firebaseContactsProvider);
                  },
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
          data: (contacts) {
            if (contacts.isEmpty) {
              return ContactsEmptyState(
                onTapExchange: () {
                  ref.read(bottomNavProvider.notifier).state = 2;
                },
              );
            }
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // プルトゥリフレッシュを有効化
              slivers: [
                // ヘッダー部分
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.contacts,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '名刺一覧',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _showAll
                                        ? '${contacts.length}枚の名刺（全件表示）'
                                        : '${contacts.length}枚の名刺'
                                            '（${contacts.take(5).length}件表示中）',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${contacts.length}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 名刺リスト
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // 表示する名刺のリストを決定
                        final displayContacts =
                            _showAll ? contacts : contacts.take(5).toList();

                        if (index < displayContacts.length) {
                          final contact = displayContacts[index];
                          final isOpen = _expanded[contact.id] ?? false;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ContactListItem(
                              key: ValueKey(contact.id),
                              contact: contact,
                              isOpen: isOpen,
                              onTap: () {
                                setState(() {
                                  _expanded[contact.id] = !isOpen;
                                });
                              },
                            ),
                          );
                        } else {
                          // 「もっと見る」ボタン
                          return _buildLoadMoreButton(contacts.length);
                        }
                      },
                      childCount: _showAll
                          ? contacts.length
                          : contacts.length > 5
                              ? 6 // 5件 + もっと見るボタン
                              : contacts.length,
                    ),
                  ),
                ),
                // 下部余白（プルトゥリフレッシュ用）
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.3, // 画面の30%の高さを確保
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
