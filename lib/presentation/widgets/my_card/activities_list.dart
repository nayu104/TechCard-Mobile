import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'activity_tile.dart';

/// 活動ログを取得し、直近10件を相対時刻で表示。
/// Repository経由の`activitiesProvider`をwatchし、
/// 空ならプレースホルダ、あれば最新順に最大10件を並べる。
class ActivitiesList extends ConsumerWidget {
  const ActivitiesList({super.key});

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分前';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}時間前';
    }
    return '${diff.inDays}日前';
  }

  @override
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
              .map((a) => ActivityTile(a.title, _relative(a.occurredAt)))
              .toList(),
        );
      },
    );
  }
}
