// 目的: 名刺一覧画面。主要要素=リスト表示＋折りたたみ詳細＋βピル。
// watch方針: 一覧はwatchで再ビルド。詳細の展開状態はローカルStateで最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/contacts/contact_list_item.dart';
import '../widgets/contacts/empty_state.dart';
import '../widgets/pills.dart';

/// 名刺一覧ページ。
/// 0件時のプレースホルダと、展開可能な連絡先カードのリストを表示する。
class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  /// 名刺一覧を取得し、展開/折りたたみ可能なリストを描画する。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final expanded = <String, bool>{};
    return Scaffold(
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return ContactsEmptyState(
              onTapExchange: () {
                ref.read(bottomNavProvider.notifier).state = 2;
              },
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('名刺リスト'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('${contacts.length}枚',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...contacts.map((c) {
                final isOpen = expanded[c.id] ?? false;
                return ContactListItem(
                  contact: c,
                  isOpen: isOpen,
                  onTap: () => expanded[c.id] = !isOpen,
                );
              })
            ],
          );
        },
      ),
    );
  }
}
