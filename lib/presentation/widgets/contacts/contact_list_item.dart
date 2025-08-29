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

  @override
  Widget build(BuildContext context) {
    final c = contact;
    return Card(
      child: Column(children: [
        ListTile(
          onTap: onTap,
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(c.name),
          subtitle: Text('@${c.userId}'),
          trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
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
                  child: Text(c.userId),
                ),
              ]),
              const SizedBox(height: 8),
              Text(c.bio.isEmpty ? '自己紹介は未設定です' : c.bio),
              const SizedBox(height: 8),
              Wrap(
                  children: c.skills
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: Chip(label: Text(s)),
                          ))
                      .toList()),
            ]),
          )
      ]),
    );
  }
}
