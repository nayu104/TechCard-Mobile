import 'package:flutter/material.dart';

/// プロフィールのヘッダー（アバター、名前、ID、役職）表示カードの中身。
class ProfileHeaderContent extends StatelessWidget {
  const ProfileHeaderContent({
    super.key,
    required this.isEditing,
    required this.controllerName,
    required this.controllerId,
    required this.displayName,
    required this.displayUserId,
    required this.displayRole,
  });

  final bool isEditing;
  final TextEditingController controllerName;
  final TextEditingController controllerId;
  final String displayName;
  final String displayUserId;
  final String displayRole;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const CircleAvatar(radius: 26, child: Icon(Icons.person_outline)),
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
                  decoration: const InputDecoration(labelText: 'ユーザーID'))
              : Text('@$displayUserId',
                  style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          Text(displayRole,
              style: TextStyle(color: Theme.of(context).hintColor)),
        ]),
      ),
    ]);
  }
}
