import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/github_user_provider.dart';

/// プロフィールのヘッダー（アバター、名前、ID、役職）表示カードの中身。
class ProfileHeaderContent extends ConsumerWidget {
  const ProfileHeaderContent({
    super.key,
    required this.isEditing,
    required this.controllerName,
    required this.controllerId,
    required this.displayName,
    required this.displayGithub,
  });

  final bool isEditing;
  final TextEditingController controllerName;
  final TextEditingController controllerId;
  final String displayName;
  final String displayGithub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final githubNameAsync = displayGithub.isEmpty
        ? const AsyncValue<String?>.data(null)
        : ref.watch(githubDisplayNameProvider(displayGithub));
    return Row(children: [
      CircleAvatar(
        radius: 26,
        backgroundImage: displayGithub.isNotEmpty
            ? NetworkImage('https://github.com/$displayGithub.png')
            : null,
        child:
            displayGithub.isNotEmpty ? null : const Icon(Icons.person_outline),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          isEditing
              ? TextField(
                  controller: controllerName,
                  decoration: const InputDecoration(labelText: '名前'))
              : Text(displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          isEditing
              ? TextField(
                  controller: controllerId,
                  decoration: const InputDecoration(labelText: 'GitHubのユーザー名'))
              : Row(children: [
                  const Icon(Icons.code, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: githubNameAsync.when(
                      loading: () => Text('GitHub: @$displayGithub',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                      error: (_, __) => Text(
                          displayGithub.isNotEmpty
                              ? 'GitHub: @$displayGithub'
                              : 'GitHub未設定',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                      data: (name) {
                        if (displayGithub.isEmpty) {
                          //displayGithubの中身が空かどうかを確認
                          return Text('GitHub未設定',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor));
                        }
                        final show = (name == null || name.isEmpty)
                            ? '@$displayGithub'
                            : name;
                        return Text('GitHub: $show',
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Theme.of(context).hintColor));
                      },
                    ),
                  ),
                ]),
        ]),
      ),
    ]);
  }
}
