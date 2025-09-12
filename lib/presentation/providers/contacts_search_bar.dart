//検索バー
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/contacts_search_provider.dart';

/// 一覧ページ上部に置く検索バー（UIだけ）
class ContactsSearchBar extends ConsumerStatefulWidget {
  const ContactsSearchBar({super.key});

  @override
  ConsumerState<ContactsSearchBar> createState() => _ContactsSearchBarState();
}

class _ContactsSearchBarState extends ConsumerState<ContactsSearchBar> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit() {
    // 入力値をプロバイダに反映（この時点ではUIに保持するだけ）
    ref.read(contactsSearchQueryProvider.notifier).state = _ctl.text;
    FocusScope.of(context).unfocus(); // キーボードを閉じる
  }

  @override
  Widget build(BuildContext context) {
    // 他所から変更されたときにテキストフィールドへ反映
    final q = ref.watch(contactsSearchQueryProvider);
    if (_ctl.text != q) {
      _ctl.text = q;
      _ctl.selection =
          TextSelection.fromPosition(TextPosition(offset: _ctl.text.length));
    }

    final extracted = extractGithubId(q);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctl,
            decoration: InputDecoration(
              labelText: 'GitHubユーザーで検索',
              hintText:
                  'https://github.com/ユーザー名 / @ユーザー名 / ユーザー名 / 名前',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_ctl.text.isNotEmpty)
                    IconButton(
                      tooltip: 'クリア',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _ctl.clear();
                        _submit();
                      },
                    ),
                  IconButton(
                    tooltip: '検索',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _submit,
                  ),
                ],
              ),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            // 入力するたびに反映したい場合は↓のコメントを外す
            // onChanged: (v) => ref.read(contactsSearchQueryProvider.notifier).state = v,
          ),
          if (extracted != null && extracted.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '抽出されたID: $extracted',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
