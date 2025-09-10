import 'package:flutter/material.dart';
import '../../../domain/models.dart';

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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildAvatar(contact.avatarUrl),
          title: Text(
            contact.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '@${contact.userId}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (contact.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  contact.bio,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOpen
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
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
        if (isOpen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザーIDバッジ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    contact.userId,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // GitHubユーザー名（あれば表示）
                if ((contact.githubUsername ?? '').isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.08),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code,
                          size: 18,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          contact.githubUsername!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 自己紹介
                Text(
                  contact.bio.isEmpty ? '自己紹介は未設定です' : contact.bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                // スキルタグ
                if (contact.skills.isNotEmpty) ...[
                  Text(
                    'スキル',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    children: contact.skills
                        .map((skill) => Padding(
                              padding:
                                  const EdgeInsets.only(right: 8, bottom: 8),
                              child: Chip(
                                label: Text(skill),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          )
      ]),
    );
  }
}
