import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
              : _GithubRow(
                  displayGithub: displayGithub,
                  githubNameAsync: githubNameAsync,
                ),
        ]),
      ),
    ]);
  }
}

class _GithubRow extends StatelessWidget {
  const _GithubRow({
    required this.displayGithub,
    required this.githubNameAsync,
  });
  final String displayGithub;
  final AsyncValue<String?> githubNameAsync;

  @override
  Widget build(BuildContext context) {
    final githubIcon = Image.asset(
      'assets/ui_image/github-mark-white.png',
      width: 16,
      height: 16,
      color: Theme.of(context).hintColor, // テーマに馴染む色へ
      colorBlendMode: BlendMode.srcIn,
    );

    final row = Row(children: [
      githubIcon,
      const SizedBox(width: 6),
      Expanded(
        child: githubNameAsync.when(
          loading: () => Text('GitHub: @${displayGithub.isNotEmpty ? displayGithub : ''}',
              style: TextStyle(color: Theme.of(context).hintColor)),
          error: (_, __) => Text(
              displayGithub.isNotEmpty
                  ? 'GitHub: @$displayGithub'
                  : 'GitHub未設定',
              style: TextStyle(color: Theme.of(context).hintColor)),
          data: (name) {
            if (displayGithub.isEmpty) {
              return Text('GitHub未設定',
                  style: TextStyle(color: Theme.of(context).hintColor));
            }
            final show = (name == null || name.isEmpty)
                ? '@$displayGithub'
                : name;
            return Text('GitHub: $show',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).hintColor));
          },
        ),
      ),
    ]);

    if (displayGithub.isEmpty) {
      return row; // 未設定時はリンクなし
    }
    return InkWell(
      onTap: () async {
        final url = Uri.parse('https://github.com/$displayGithub');
        // ignore: deprecated_member_use
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: row,
    );
  }
}
