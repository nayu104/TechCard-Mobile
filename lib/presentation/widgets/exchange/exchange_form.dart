import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../domain/models.dart';
import '../../providers/providers.dart';
import '../custom_text_field.dart';
import '../gold_gradient_button.dart';
import 'user_preview_dialog.dart';

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

      // 検索タイプ選択（ラジオとラベルを1まとまりにして折り返し時も分離しない）
      Wrap(
        spacing: 16,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _RadioOption<SearchType>(
            value: SearchType.userId,
            groupValue: _searchType,
            label: 'ユーザーID',
            onChanged: (v) => setState(() => _searchType = v),
          ),
          _RadioOption<SearchType>(
            value: SearchType.github,
            groupValue: _searchType,
            label: 'GitHub名',
            onChanged: (v) => setState(() => _searchType = v),
          ),
        ],
      ),

      const SizedBox(height: 12),
      CustomTextField(
        controller: _controller,
        labelText: _searchType == SearchType.userId ? 'ユーザーID' : 'GitHub名',
      ),
      const SizedBox(height: 12),
      GoldGradientButton(
        icon: Icons.search,
        label: 'ユーザーを検索',
        onPressed: () async {
          final searchText = _controller.text.trim();
          if (searchText.isEmpty) {
            await Fluttertoast.showToast(msg: 'ユーザーIDまたはGitHub名を入力してください');
            return;
          }

          if (_searchType == SearchType.userId) {
            // ユーザーID検索の場合はプレビューダイアログを表示
            if (!isValidUserId(searchText)) {
              await Fluttertoast.showToast(msg: 'ユーザーIDが不正です');
              return;
            }
            showDialog<void>(
              context: context,
              builder: (context) => UserSearchResultDialog(userId: searchText),
            );
          } else {
            // GitHub名検索の場合は従来通り直接追加
            final result = await exchange.exchangeByGithubUsername(searchText);
            await Fluttertoast.showToast(msg: result.message);
            if (result.added) {
              ref.invalidate(contactsProvider);
              ref.invalidate(firebaseProfileProvider);
            }
          }
        },
      ),
    ]);
  }
}

enum SearchType { userId, github }

class _RadioOption<T> extends StatelessWidget {
  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
