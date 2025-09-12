import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models.dart';
import '../pills.dart';

class ContactListItem extends StatelessWidget {
  const ContactListItem(
      {super.key,
      required this.contact,
      required this.isOpen,
      required this.onTap});
  final Contact contact;
  final bool isOpen;
  final VoidCallback onTap;

  /// アバター画像を構築する
  Widget _buildAvatar(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      // FirebaseにアバターURLがある場合は画像を表示
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // 画像読み込みエラー時はデフォルトアイコンを表示
          // アバター画像読み込みエラー（デフォルトアイコンにフォールバック）
        },
      );
    } else {
      // アバターURLがない場合はデフォルトアイコンを表示
      return const CircleAvatar(
        backgroundColor: Colors.amber,
        child: Icon(
          Icons.person_outline,
          color: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final onSurface = Theme.of(context).colorScheme.onSurface; // 未使用
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildAvatar(contact.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // GitHub 行（アイコン付き・タップで外部ブラウザへ）
                  _GithubLine(username: contact.githubUsername ?? ''),
                ],
              ),
            ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: isOpen
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ]),
          if (isOpen) ...[
            const SizedBox(height: 12),

            // GitHubのボックス表示はしない（ヘッダー行に統一）

            // ひとことメッセージ（MyCard と同じ表記）
            Text('ひとことメッセージ：',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              contact.bio.isEmpty ? '未設定' : contact.bio,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 12),

            if (contact.skills.isNotEmpty) ...[
              Text('スキル',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: contact.skills
                    .map((skill) => SkillChip(label: skill))
                    .toList(),
              ),
            ],
          ],
        ]),
      ),
    );
  }
}

class _GithubLine extends StatelessWidget {
  const _GithubLine({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    final isEmpty = username.isEmpty;
    final text = isEmpty ? '未設定' : username;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/ui_image/github-mark-white.png',
          width: 16,
          height: 16,
          color: Theme.of(context).hintColor,
          colorBlendMode: BlendMode.srcIn,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      ],
    );

    if (isEmpty) return row; // 未設定時はリンクなし

    return InkWell(
      onTap: () async {
        final url = Uri.parse('https://github.com/$username');
        // ignore: deprecated_member_use
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: row,
    );
  }
}
