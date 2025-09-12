import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../domain/models.dart';
import '../providers/providers.dart';
import '../providers/skills/editing_skills_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/skills/editable_skills.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.profile});
  final MyProfile profile;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _controllerName;
  late final TextEditingController _controllerMessage;

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget.profile.name);
    _controllerMessage = TextEditingController(text: widget.profile.message);
    // 初期スキルを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editingSkillsProvider.notifier).state = [
        ...widget.profile.skills
      ];
    });
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _controllerName,
                labelText: '名前(8文字まで)',
                hintText: 'ここに入力してください',
                maxLength: 8,
              ),
              const SizedBox(height: 16),
              // GitHub入力欄は仕様により削除
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllerMessage,
                labelText: 'ひとこと（50文字まで）',
                hintText: '自己紹介やメッセージを入力してください',
                maxLines: 3,
                validator: (v) {
                  if (v != null && v.length > 50) {
                    return '50文字以内で入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('スキル', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              EditableSkills(initial: const []),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final profile = widget.profile;
    final updated = MyProfile(
      avatar: profile.avatar,
      name: _controllerName.text,
      userId: _safeUserId(profile.userId, _controllerName.text),
      createdAt: profile.createdAt,
      email: profile.email,
      friendIds: profile.friendIds,
      github: profile.github,
      message: _controllerMessage.text,
      skills: ref.read(editingSkillsProvider),
      updatedAt: DateTime.now(),
    );
    try {
      final saveFunction = ref.read(firebaseUpdateProfileProvider);
      await saveFunction(updated);
      await Fluttertoast.showToast(msg: '保存しました');
      ref.invalidate(firebaseProfileProvider);
      ref.read(editingSkillsProvider.notifier).state = const [];
      if (mounted) Navigator.of(context).maybePop();
    } on Exception catch (_) {
      await Fluttertoast.showToast(msg: '保存に失敗しました');
    }
  }
}

// GitHub入力は削除されたため、正規化ロジックは未使用

String _safeUserId(String? current, String name) {
  final userIdRegex = RegExp(r'^[A-Za-z0-9_\-]+$');
  if (current != null && userIdRegex.hasMatch(current)) return current;
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  return slug.isNotEmpty
      ? slug
      : 'user_${DateTime.now().millisecondsSinceEpoch}';
}
