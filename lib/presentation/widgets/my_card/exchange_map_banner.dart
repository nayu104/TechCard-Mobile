import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/usecase_providers.dart';
import '../common/gradient_outline_pill_button.dart';

class ExchangeMapBanner extends ConsumerStatefulWidget {
  const ExchangeMapBanner({super.key});

  @override
  ConsumerState<ExchangeMapBanner> createState() => _ExchangeMapBannerState();
}

class _ExchangeMapBannerState extends ConsumerState<ExchangeMapBanner> {
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
      loading: () => _buildCtaCard(context, null, isLoading: true),
      error: (_, __) => _buildCtaCard(context, null, hasError: true),
      data: (items) => _buildCtaCard(context, items),
    );
  }

  Widget _buildCtaCard(BuildContext context, List<Map<String, dynamic>>? items,
      {bool isLoading = false, bool hasError = false}) {
    // 件数は説明テキストを表示しない設計に変更（ボタンのみ）
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFCC80),
                    Color(0xFFFF8F00),
                    Color(0xFFF4511E)
                  ],
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
              child: AbsorbPointer(
                absorbing: isLoading || hasError,
                child: GradientOutlinePillButton(
                  icon: Icons.fullscreen,
                  label: '交換した場所を見る',
                  onPressed: () =>
                      _showFullScreenMap(context, items ?? const []),
                ),
              ),
            ),
          ],
        ),
      ),
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

    // 初期位置: デフォルト座標は表示しない（マーカーが無い場合は世界全体）
    final initial =
        markers.isNotEmpty ? markers.first.position : const LatLng(0, 0);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox.expand(
            // Webで真っ白になるのを防ぐため、必ずサイズを確保
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: initial, zoom: markers.isNotEmpty ? 12 : 1),
              onMapCreated: (c) async {
                _controller = c;
                // 全ピンが収まるように調整
                if (bounds != null) {
                  await Future.delayed(const Duration(milliseconds: 120));
                  await _controller?.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 48),
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

  // 削除: ローディング/エラー専用バナー（CTAカードに統合）

  // 削除: 空バナー（常にCollapsedBannerに統一）
}

// 削除: 旧バナー
