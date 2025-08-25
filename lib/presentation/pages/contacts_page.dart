// 目的: 名刺一覧画面。主要要素=リスト表示＋折りたたみ詳細＋βピル。
// watch方針: 一覧はwatchで再ビルド。詳細の展開状態はローカルStateで最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/global_providers.dart';
import '../widgets/pills.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});
  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final Map<String, bool> _expanded = {};

  @override

  /// 名刺一覧を取得し、展開/折りたたみ可能なリストを描画する。
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('名刺一覧'), actions: const [
        Padding(padding: EdgeInsets.only(right: 12), child: BetaPill())
      ]),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.contact_page_outlined, size: 64),
                const SizedBox(height: 8),
                const Text('まだ名刺がありません'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(bottomNavProvider.notifier).state = 2,
                  child: const Text('名刺を交換する'),
                ),
              ]),
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
                final isOpen = _expanded[c.id] ?? false;
                // レイアウト意図: タップ領域を広くし、詳細は段階的開閉で可読性維持。
                return Card(
                  child: Column(children: [
                    ListTile(
                      onTap: () => setState(() => _expanded[c.id] = !isOpen),
                      leading:
                          const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(c.name),
                      subtitle: Text('@${c.userId}'),
                      trailing:
                          Icon(isOpen ? Icons.expand_less : Icons.expand_more),
                    ),
                    if (isOpen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(c.userId),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => Clipboard.setData(
                                      ClipboardData(text: c.userId)),
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: 'コピー',
                                ),
                              ]),
                              const SizedBox(height: 8),
                              Text(c.bio.isEmpty ? '自己紹介は未設定です' : c.bio),
                              const SizedBox(height: 8),
                              Wrap(
                                  children: c.skills
                                      .map((s) => Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8, bottom: 8),
                                          child: Chip(label: Text(s))))
                                      .toList()),
                            ]),
                      )
                  ]),
                );
              })
            ],
          );
        },
      ),
    );
  }
}
