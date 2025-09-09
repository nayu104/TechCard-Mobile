// 目的: 名刺一覧画面。主要要素=リスト表示＋折りたたみ詳細＋βピル。
// watch方針: 一覧はwatchで再ビルド。詳細の展開状態はローカルStateで最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/contacts/contact_list_item.dart';
import '../widgets/contacts/empty_state.dart';

// 追加 import（検索バーと検索クエリ）
import '../widgets/contacts_search_bar.dart';
import '../providers/contacts_search_provider.dart'; // クエリのprovider

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

  /// 「もっと見る」ボタン
  Widget _buildLoadMoreButton(int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => setState(() => _showAll = true),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.expand_more, color: Theme.of(context).colorScheme.primary),
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

  // 正規化 & マッチ（GitHub URL/@ID/名前/会社/役職/スキル/メモを横断）
  bool _matches(dynamic c, String qRaw) {
    if (qRaw.trim().isEmpty) return true;
    String norm(String s) => s.trim().toLowerCase().replaceAll('　', ' ');
    final q = norm(qRaw);

    final extracted = extractGithubId(qRaw); // 既存のヘルパー想定
    final qOrId = norm((extracted != null && extracted.isNotEmpty) ? extracted : q);

    final name   = (c.name ?? c.displayName ?? '').toString();
    final gh     = (c.github ?? c.githubUsername ?? c.handle ?? '').toString();
    final company= (c.company ?? '').toString();
    final title  = (c.title ?? '').toString();
    final skills = (c.skills is List ? (c.skills as List).join(' ') : '').toString();
    final note   = (c.note ?? '').toString();

    final hay = [
      name, gh, company, title, skills, note,
    ].map(norm).join(' ');

    return hay.contains(qOrId);
  }

  /// 名刺一覧を取得し、検索→展開/折りたたみ可能リストを描画
  @override
  Widget build(BuildContext context) {
    // 一覧データ
    final contactsAsync = ref.watch(firebaseContactsProvider);
    // 検索クエリ
    final query = ref.watch(contactsSearchQueryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(firebaseContactsProvider);
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('読み込みに失敗しました', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'エラー: $e',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(firebaseContactsProvider),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
          data: (contacts) {
            // 全体が0件なら既存の空状態
            if (contacts.isEmpty) {
              return ContactsEmptyState(
                onTapExchange: () {
                  ref.read(bottomNavProvider.notifier).state = 2;
                },
              );
            }

            // 検索適用
            final filtered = contacts.where((c) => _matches(c, query)).toList();

            // 検索結果が0件のとき
            if (filtered.isEmpty) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverToBoxAdapter(child: ContactsSearchBar()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 48),
                              SizedBox(height: 8),
                              Text('該当する名刺が見つかりませんでした'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 通常表示（検索バー + ヘッダー + リスト）
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: ContactsSearchBar()),

                // ヘッダー
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.contacts,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('名刺一覧',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _showAll
                                        ? '${filtered.length}枚の名刺（全件表示）'
                                        : '${filtered.length}枚の名刺'
                                          '（${filtered.take(5).length}件表示中）',
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
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filtered.length}',
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

                // 名刺リスト（filtered を使用）
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final displayContacts =
                            _showAll ? filtered : filtered.take(5).toList();

                        if (index < displayContacts.length) {
                          final contact = displayContacts[index];
                          final isOpen = _expanded[contact.id] ?? false;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ContactListItem(
                              key: ValueKey(contact.id),
                              contact: contact,
                              isOpen: isOpen,
                              onTap: () => setState(
                                () => _expanded[contact.id] = !isOpen,
                              ),
                            ),
                          );
                        } else {
                          // 5件超かつ未展開なら「もっと見る」
                          return _buildLoadMoreButton(filtered.length);
                        }
                      },
                      childCount: _showAll
                          ? filtered.length
                          : filtered.length > 5
                              ? 6 // 5件 + もっと見るボタン
                              : filtered.length,
                    ),
                  ),
                ),

                // 下部余白（プルトゥリフレッシュ用）
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
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
