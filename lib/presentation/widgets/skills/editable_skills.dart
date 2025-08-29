import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/skills/editing_skills_provider.dart';
import 'skills_options.dart';

/// 編集モード時にスキルの追加/削除/選択を行うウィジェット。
class EditableSkills extends ConsumerWidget {
  const EditableSkills({super.key, required this.initial});
  final List<String> initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(editingSkillsProvider);

    if (selected.isEmpty && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editingSkillsProvider.notifier).state = [...initial];
      });
    }

    final controller = TextEditingController();

    void addSkill(String value) {
      final text = value.trim();
      if (text.isEmpty) return;
      final next = {...ref.read(editingSkillsProvider), text}.toList();
      ref.read(editingSkillsProvider.notifier).state = next;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: ref
              .watch(editingSkillsProvider)
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: InputChip(
                      label: Text(s),
                      onDeleted: () {
                        final next = [...ref.read(editingSkillsProvider)]
                          ..remove(s);
                        ref.read(editingSkillsProvider.notifier).state = next;
                      },
                    ),
                  ))
              .toList(),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'スキルを追加（Enterで追加）',
          ),
          onSubmitted: (v) {
            addSkill(v);
            controller.clear();
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          children: kSkillOptions.map((opt) {
            final isSelected = ref.watch(editingSkillsProvider).contains(opt);
            return Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: FilterChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (sel) {
                  final cur = {...ref.read(editingSkillsProvider)};
                  if (sel) {
                    cur.add(opt);
                  } else {
                    cur.remove(opt);
                  }
                  ref.read(editingSkillsProvider.notifier).state = cur.toList();
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
