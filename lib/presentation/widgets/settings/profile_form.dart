import 'package:flutter/material.dart';
import '../../../domain/models.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.name,
    required this.userId,
    required this.bio,
    required this.company,
    required this.role,
    required this.github,
    required this.onSave,
  });

  final TextEditingController name;
  final TextEditingController userId;
  final TextEditingController bio;
  final TextEditingController company;
  final TextEditingController role;
  final TextEditingController github;
  final ValueChanged<UserProfile> onSave;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('基本情報', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: '名前')),
            TextField(
                controller: userId,
                decoration: const InputDecoration(labelText: 'ユーザーID')),
            TextField(
                controller: bio,
                decoration: const InputDecoration(labelText: '自己紹介'),
                maxLines: 4),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('職業情報', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
                controller: company,
                decoration: const InputDecoration(labelText: '会社名')),
            TextField(
                controller: role,
                decoration: const InputDecoration(labelText: '役職')),
            TextField(
                controller: github,
                decoration: const InputDecoration(labelText: 'GitHubユーザー名')),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () {
          final updated = UserProfile(
            name: name.text,
            userId: userId.text,
            bio: bio.text,
            company: company.text.isEmpty ? null : company.text,
            role: role.text.isEmpty ? null : role.text,
            githubUsername: github.text.isEmpty ? null : github.text,
          );
          onSave(updated);
        },
        child: const Text('保存'),
      )
    ]);
  }
}
