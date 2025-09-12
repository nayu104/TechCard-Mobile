/*

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
  bool _isRefreshing = false; // リフレッシュ状態

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

  /// 名刺一覧タブ
  Widget _buildContactsTab(BuildContext context) {
    final contactsAsync = ref.watch(firebaseContactsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isRefreshing = true);
        try {
          ref.invalidate(firebaseContactsProvider);
          await ref.read(firebaseContactsProvider.future);
        } finally {
          if (mounted) setState(() => _isRefreshing = false);
        }
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
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('読み込みに失敗しました', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(firebaseContactsProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ContactsEmptyState(
                  onTapExchange: () =>
                      ref.read(bottomNavProvider.notifier).state = 2,
                  isLoading: _isRefreshing,
                ),
              ),
            );
          }
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
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
                                    ? '${contacts.length}枚の名刺（全件表示）'
                                    : '${contacts.length}枚の名刺（${contacts.take(5).length}件表示中）',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
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
                          child: Text('${contacts.length}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                        return _buildLoadMoreButton(contacts.length);
                      }
                    },
                    childCount: _showAll
                        ? contacts.length
                        : contacts.length > 5
                            ? 6
                            : contacts.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ],
          );
        },
      ),
    );
  }

  /// 交換申請タブ
  Widget _buildRequestsTab(BuildContext context) {
    final requestsAsync = ref.watch(friendRequestsProvider);
    final accept = ref.read(acceptFriendRequestActionProvider);
    final decline = ref.read(declineFriendRequestActionProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(friendRequestsProvider);
        await ref.read(friendRequestsProvider.future);
      },
      child: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Image(image: AssetImage('assets/ui_image/no_request.png'), width: 160)),
                SizedBox(height: 8),
                Center(child: Text('交換申請はありません')),
                SizedBox(height: 200),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final req = requests[index];
              final id = req['id'] as String;
              final senderName = (req['senderName']?.toString() ?? '').isNotEmpty
                  ? req['senderName'].toString()
                  : 'ユーザー';
              final senderAvatar = req['senderAvatar']?.toString();
              return Card(
                child: ListTile(
                  leading: senderAvatar != null && senderAvatar.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(senderAvatar))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(senderName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: null,
                  trailing: Wrap(spacing: 8, children: [
                    OutlinedButton(
                      onPressed: () async {
                        await decline(id);
                      },
                      child: const Text('見送る'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await accept(id);
                      },
                      child: const Text('承認'),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 名刺一覧を取得し、展開/折りたたみ可能なリストを描画する。
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              tabs: [
                const Tab(text: '名刺一覧'),
                Tab(
                  text: ref.watch(friendRequestsCountProvider) > 0
                      ? '交換申請 (${ref.watch(friendRequestsCountProvider)})'
                      : '交換申請',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildContactsTab(context),
            _buildRequestsTab(context),
          ],
        ),
      ),
    );
  }
}

*/

// lib/presentation/pages/contacts_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/contacts/contact_list_item.dart';
import '../widgets/contacts/empty_state.dart';
// 先頭の import 群に追加
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/usecase_providers.dart';
// デモSeederを使うため追加
import '../../infrastructure/demo_seeder.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final Map<String, bool> _expanded = {};
  var _showAll = false; // 全件表示フラグ

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(firebaseContactsProvider);

    return Scaffold(
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (contacts) {
          // 🔹 ここを修正
          if (contacts.isEmpty) {
            return ContactsEmptyState(
              onTapExchange: () {
                // 既存の「名刺交換する」ボタンの処理
                ref.read(bottomNavProvider.notifier).state = 2;
              },
             onTapSeedDemo: () async {
                try {
                  // ここで FirebaseAuth から直接 UID を取得
                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  if (uid == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('デモ投入にはサインインが必要です')),
                      );
                    }
                    return;
                  }

                  await ref.read(demoSeederProvider).seed(ownerUid: uid);
                  ref.invalidate(firebaseContactsProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('デモ名刺を追加しました')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('デモ投入に失敗しました: $e')),
                    );
                  }
                }
              },

            );
          }

          // 👇 ここから先は従来の「名刺一覧リスト」の表示処理
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final isOpen = _expanded[contact.id] ?? false;
              return ContactListItem(
                contact: contact,
                isOpen: isOpen,
                onTap: () {
                  setState(() {
                    _expanded[contact.id] = !isOpen;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
