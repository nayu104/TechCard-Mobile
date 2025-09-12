import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techcard_mobile/presentation/widgets/custom_text_field.dart';

import '../../providers/skills/editing_skills_provider.dart';
import 'skills_options.dart';

/// 編集モード時にスキルの追加/削除/選択を行うウィジェット。
/// 検索、選択済み、候補リストのUIを提供する。
class EditableSkills extends ConsumerStatefulWidget {
  const EditableSkills({super.key, required this.initial});
  final List<String> initial;

  @override
  ConsumerState<EditableSkills> createState() => _EditableSkillsState();
}

class _EditableSkillsState extends ConsumerState<EditableSkills> {
  // --- State Management ---
  /// 検索テキストフィールドを管理するためのコントローラー。
  final _searchController = TextEditingController();

  /// 検索クエリの現在値を保持する状態変数。
  var _searchQuery = '';

  // --- Lifecycle Hooks ---
  @override
  void initState() {
    super.initState();
    // 検索コントローラーの入力値をリッスンし、変更があればUIを再描画する。
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });

    // このウィジェットがビルドされた直後に一度だけ実行される。
    // 親から渡された初期スキルリストを、Riverpodの状態に設定する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(editingSkillsProvider).isEmpty &&
          widget.initial.isNotEmpty) {
        ref.read(editingSkillsProvider.notifier).state = [...widget.initial];
      }
    });
  }

  @override
  void dispose() {
    // ウィジェットが破棄される際に、コントローラーも破棄してメモリリークを防ぐ。
    _searchController.dispose();
    super.dispose();
  }

  // --- Business Logic ---
  /// スキルをRiverpodの状態リストに追加する。重複は許さない。
  void _addSkill(String skill) {
    final text = skill.trim();
    if (text.isEmpty) {
      return; // 空白文字は追加しない
    }

    final skills = ref.read(editingSkillsProvider);
    if (skills.length > 4) {
      // 0から数えるので「 > 4 」と表記する
      Fluttertoast.showToast(
        msg: 'スキルは最大5個までしか保存できません',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14,
      );
      return;
    }

    final currentSkills = ref.read(editingSkillsProvider);
    if (!currentSkills.contains(text)) {
      ref.read(editingSkillsProvider.notifier).state = [...currentSkills, text];
    }
  }

  /// スキルをRiverpodの状態リストから削除する。
  void _removeSkill(String skill) {
    ref.read(editingSkillsProvider.notifier).state = [
      ...ref.read(editingSkillsProvider)
    ]..remove(skill);
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    // Riverpodの状態を監視し、変更があればこのウィジェットを再ビルドする。
    final selectedSkills = ref.watch(editingSkillsProvider);

    // 候補スキルリストを動的に生成する。
    // 条件: 1. まだ選択されていない & 2. 検索クエリに一致する
    final availableOptions = kSkillOptions.where((opt) {
      final isNotSelected = !selectedSkills.contains(opt);
      final matchesQuery = _searchQuery.isEmpty ||
          opt.toLowerCase().contains(_searchQuery.toLowerCase());
      return isNotSelected && matchesQuery;
    }).toList();

    // --- Widget Layout ---
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- 1. 検索バー ---
              CustomTextField(
                controller: _searchController,
                labelText: 'スキルを検索して追加する',
                prefixIcon: const Icon(Icons.search, size: 20),
                // 入力がある時だけクリアボタンを表示する
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _searchController.clear,
                      )
                    : null,
              ),
              const SizedBox(height: 24),

              // --- 2. 選択済みスキル ---

              if (selectedSkills.isNotEmpty)
                const Text('追加されたスキル',
                    style: TextStyle(fontWeight: FontWeight.bold)),

              // 横スクロールするリストで選択済みスキルを表示
              if (selectedSkills.isNotEmpty)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedSkills.length,
                    itemBuilder: (context, index) {
                      final skill = selectedSkills[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFCC80),
                              Color(0xFFFF8F00),
                              Color(0xFFF4511E)
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.5), // 枠線として見せる
                          child: InputChip(
                            label: Text(skill),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            onDeleted: () => _removeSkill(skill),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            deleteIconColor:
                                Theme.of(context).colorScheme.onSurface,
                            deleteIcon: const Icon(
                              Icons.cancel,
                              size: 14,
                            ),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                  ),
                ),

              SizedBox(height: selectedSkills.isEmpty ? 0 : 24),

              // --- 3. 候補スキル ---
              const Text('候補', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 候補エリアが長くなりすぎないように最大高を設定し、スクロール可能にする

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: availableOptions
                    .map((opt) => ActionChip(
                          label: Text(opt),
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 12),
                          onPressed: () {
                            _addSkill(opt);
                            _searchController.clear();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ))
                    .toList(),
              ),
            ]),
      ),
    );
  }
}
