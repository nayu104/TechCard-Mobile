import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/usecase_providers.dart';

class ExchangeMapBanner extends ConsumerStatefulWidget {
  const ExchangeMapBanner({super.key});

  @override
  ConsumerState<ExchangeMapBanner> createState() => _ExchangeMapBannerState();
}

class _ExchangeMapBannerState extends ConsumerState<ExchangeMapBanner> {
  bool _expanded = false; // 折りたたみ可能
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mapExchangesProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: _expanded ? 240 : 72,
                  padding: const EdgeInsets.all(12),
                  child: _expanded
                      ? Stack(
                          children: [
                            // 折りたたみボタン（左上）
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Tooltip(
                                message: '折りたたむ',
                                child: FloatingActionButton.small(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  onPressed: () =>
                                      setState(() => _expanded = false),
                                  child: const Icon(Icons.keyboard_arrow_up),
                                ),
                              ),
                            ),
                            // マップ本体（必ずサイズを確保）
                            Positioned.fill(child: _buildMap(context, items)),
                            // 全画面ボタン（右上）
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Tooltip(
                                message: '全画面',
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withValues(alpha: 0.8),
                                    ),
                                    icon: const Icon(Icons.fullscreen),
                                    onPressed: () =>
                                        _showFullScreenMap(context, items),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _CollapsedBanner(count: items.length),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenMap(
      BuildContext context, List<Map<String, dynamic>> items) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 背景タップで閉じる
      barrierLabel: 'close-map',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, anim1, anim2) {
        return WillPopScope(
          onWillPop: () async => true, // 戻るボタンで閉じる
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('交換履歴マップ'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).maybePop(),
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  // 画面いっぱいにマップを表示
                  Positioned.fill(child: _buildMap(context, items)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap(BuildContext context, List<Map<String, dynamic>> items) {
    final markers = <Marker>{};
    LatLngBounds? bounds;

    for (final m in items) {
      final loc = m['location'];
      if (loc is GeoPoint) {
        final latLng = LatLng(loc.latitude, loc.longitude);
        markers.add(
          Marker(
            markerId: MarkerId(m['id'] as String),
            position: latLng,
            infoWindow: InfoWindow(
              title: (m['peerName'] as String?)?.isNotEmpty == true
                  ? m['peerName'] as String
                  : (m['peerUserId'] as String? ?? ''),
              snippet: _formatTimestamp(m['exchangedAt']),
            ),
          ),
        );
        bounds = _extend(bounds, latLng);
      }
    }

    final initial = markers.isNotEmpty
        ? markers.first.position
        : const LatLng(35.681236, 139.767125); // 東京駅

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox.expand(
            // Webで真っ白になるのを防ぐため、必ずサイズを確保
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: initial, zoom: markers.length > 1 ? 8 : 12),
              onMapCreated: (c) async {
                _controller = c;
                // 全ピンが収まるように調整
                if (bounds != null) {
                  await Future.delayed(const Duration(milliseconds: 120));
                  await _controller?.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds!, 48),
                  );
                }
              },
              markers: markers,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
  }

  LatLngBounds _extend(LatLngBounds? current, LatLng p) {
    if (current == null) {
      return LatLngBounds(southwest: p, northeast: p);
    }
    final sw = LatLng(
      p.latitude < current.southwest.latitude
          ? p.latitude
          : current.southwest.latitude,
      p.longitude < current.southwest.longitude
          ? p.longitude
          : current.southwest.longitude,
    );
    final ne = LatLng(
      p.latitude > current.northeast.latitude
          ? p.latitude
          : current.northeast.latitude,
      p.longitude > current.northeast.longitude
          ? p.longitude
          : current.northeast.longitude,
    );
    return LatLngBounds(southwest: sw, northeast: ne);
  }

  Widget _buildLoadingBanner() {
    return _CollapsedBanner(
      count: 0,
      isLoading: true,
    );
  }

  Widget _buildErrorBanner() {
    return _CollapsedBanner(
      count: 0,
      hasError: true,
    );
  }

  Widget _buildEmptyBanner() {
    return _CollapsedBanner(
      count: 0,
      isEmpty: true,
    );
  }
}

class _CollapsedBanner extends StatelessWidget {
  const _CollapsedBanner({
    required this.count,
    this.isLoading = false,
    this.hasError = false,
    this.isEmpty = false,
  });
  final int count;
  final bool isLoading;
  final bool hasError;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFCC80), Color(0xFFFF8F00), Color(0xFFF4511E)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const Icon(Icons.map, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('交換マップ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                _getBannerText(),
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.7), fontSize: 12),
              )
            ],
          ),
        ),
        const Icon(Icons.keyboard_arrow_down),
      ],
    );
  }

  String _getBannerText() {
    if (isLoading) {
      return '交換履歴を読み込み中...';
    } else if (hasError) {
      return '交換履歴の読み込みに失敗しました';
    } else if (isEmpty) {
      return '交換履歴がまだありません。名刺交換をしてみましょう！';
    } else {
      return '過去の交換地点を地図で確認できます';
    }
  }
}
