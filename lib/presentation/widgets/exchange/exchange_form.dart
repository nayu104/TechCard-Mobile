import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/providers.dart';
import '../custom_text_field.dart';
import '../gold_gradient_button.dart';

/// ユーザーIDまたはGitHub名を入力して名刺交換を行うフォーム。
/// 入力→サービス呼び出し→結果をトースト表示し、成功時は一覧をinvalidate。
class ExchangeForm extends ConsumerStatefulWidget {
  const ExchangeForm({super.key});

  @override
  ConsumerState<ExchangeForm> createState() => _ExchangeFormState();
}

class _ExchangeFormState extends ConsumerState<ExchangeForm> {
  final _controller = TextEditingController();
  SearchType _searchType = SearchType.userId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exchange = ref.watch(exchangeServiceProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(
          children: [Icon(Icons.search), SizedBox(width: 8), Text('ユーザー検索')]),
      const SizedBox(height: 12),

      // 検索タイプ選択
      Row(
        children: [
          Expanded(
            child: RadioListTile<SearchType>(
              title: const Text('ユーザーID'),
              value: SearchType.userId,
              groupValue: _searchType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _searchType = value;
                  });
                }
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: RadioListTile<SearchType>(
              title: const Text('GitHub名'),
              value: SearchType.github,
              groupValue: _searchType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _searchType = value;
                  });
                }
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),
      CustomTextField(
        controller: _controller,
        labelText: _searchType == SearchType.userId ? 'ユーザーID' : 'GitHub名',
        hintText: _searchType == SearchType.userId
            ? 'ユーザーID入力（例: demo）'
            : 'GitHub名入力（例: octocat）',
      ),
      const SizedBox(height: 12),
      GoldGradientButton(
        icon: Icons.person_add_alt_1,
        label: '名刺交換する',
        onPressed: () async {
          final result = _searchType == SearchType.userId
              ? await exchange.exchangeByUserId(_controller.text.trim())
              : await exchange
                  .exchangeByGithubUsername(_controller.text.trim());
          await Fluttertoast.showToast(msg: result.message);
          if (result.added) {
            ref.invalidate(contactsProvider);
          }
        },
      ),
    ]);
  }
}

enum SearchType { userId, github }
