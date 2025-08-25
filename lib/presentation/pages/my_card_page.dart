// 目的: 自分の名刺編集/表示。主要要素=プロフィール編集、QR表示、活動履歴。
// watch方針: プロフィールはwatch、編集ON/OFFはStateProviderで再ビルド最小化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/global_providers.dart';
import '../widgets/gold_gradient_button.dart';
import '../widgets/pills.dart';
import '../../domain/models.dart';

class MyCardPage extends ConsumerWidget {
  const MyCardPage({super.key});

  @override

  /// プロフィールの閲覧/編集UIとQR表示、最近の活動リストを描画する。
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ名刺'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: BetaPill())
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました')),
        data: (profile) {
          final controllerName =
              TextEditingController(text: profile?.name ?? '');
          final controllerId =
              TextEditingController(text: profile?.userId ?? '');
          final controllerBio = TextEditingController(text: profile?.bio ?? '');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(isEditing ? '編集ON' : '編集OFF'),
                  Switch(
                    value: isEditing,
                    onChanged: (v) =>
                        ref.read(isEditingProvider.notifier).state = v,
                  )
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const CircleAvatar(
                              radius: 26, child: Icon(Icons.person_outline)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isEditing
                                      ? TextField(
                                          controller: controllerName,
                                          decoration: const InputDecoration(
                                              labelText: '名前'))
                                      : Text(profile?.name ?? '未設定',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  isEditing
                                      ? TextField(
                                          controller: controllerId,
                                          decoration: const InputDecoration(
                                              labelText: 'ユーザーID'))
                                      : Text('@${profile?.userId ?? 'handle'}',
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor)),
                                  const SizedBox(height: 4),
                                  Text(
                                      profile?.role ??
                                          'Frontend Engineer at Tech Company',
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor)),
                                ]),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.08),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.local_cafe_outlined, size: 16),
                                SizedBox(width: 6),
                                Text('hoge')
                              ]),
                        ),
                        const SizedBox(height: 12),
                        isEditing
                            ? TextField(
                                controller: controllerBio,
                                maxLines: 5,
                                decoration:
                                    const InputDecoration(labelText: '自己紹介'),
                              )
                            : Text(profile?.bio ?? ''),
                        const SizedBox(height: 12),
                        // レイアウト意図: 技術タグはWrapで改行し、タップしやすい余白を確保。
                        Wrap(
                            children: (profile?.skills ??
                                    [
                                      'React',
                                      'TypeScript',
                                      'Next.js',
                                      'Tailwind CSS'
                                    ])
                                .map((s) => SkillChip(label: s))
                                .toList()),
                      ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final handle = profile?.userId ?? controllerId.text;
                      await Clipboard.setData(ClipboardData(text: '@$handle'));
                      await Fluttertoast.showToast(msg: 'コピーしました');
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('IDコピー'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GoldGradientButton(
                    icon: Icons.qr_code_2,
                    label: 'QRコード',
                    onPressed: () {
                      final id = profile?.userId ?? controllerId.text;
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          content:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            QrImageView(
                                data: id.isEmpty ? 'demo' : id, size: 220),
                            const SizedBox(height: 8),
                            Text('@$id'),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: const [
                Expanded(child: _StatCard(title: 'つながり', value: '4')),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: '今月の交換', value: '3')),
              ]),
              const SizedBox(height: 12),
              const Text('最近の活動',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const _ActivitiesList(),
              const SizedBox(height: 24),
              if (isEditing)
                ElevatedButton(
                  onPressed: () async {
                    final updated = UserProfile(
                      name: controllerName.text,
                      userId: controllerId.text,
                      bio: controllerBio.text,
                    );
                    try {
                      final uc =
                          await ref.read(updateProfileUseCaseProvider.future);
                      await uc(updated);
                      await Fluttertoast.showToast(msg: '保存しました');
                      ref.invalidate(profileProvider);
                    } on Exception {
                      await Fluttertoast.showToast(msg: '保存に失敗しました');
                    }
                  },
                  child: const Text('保存'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;
  @override

  /// 統計数値をカードで表示。
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title),
        ]),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(this.text, this.time);
  final String text;
  final String time;
  @override

  /// 活動項目を1行で表示。
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 10,
          height: 10,
          decoration:
              const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
      title: Text(text),
      trailing:
          Text(time, style: TextStyle(color: Theme.of(context).hintColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _ActivitiesList extends ConsumerWidget {
  const _ActivitiesList();
  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    return '${diff.inDays}日前';
  }

  @override

  /// 活動ログを取得し、直近10件を相対時刻で表示。
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    return activities.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
      data: (list) {
        final sorted = [...list]
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        final show = sorted.take(10).toList();
        if (show.isEmpty) {
          return Text('活動はまだありません',
              style: TextStyle(color: Theme.of(context).hintColor));
        }
        return Column(
          children: show
              .map((a) => _ActivityTile(a.title, _relative(a.occurredAt)))
              .toList(),
        );
      },
    );
  }
}
