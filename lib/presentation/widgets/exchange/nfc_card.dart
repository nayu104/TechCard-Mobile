import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../domain/entities/contact.dart';
import '../../providers/providers.dart';
import '../gold_gradient_button.dart';

/// NFC名刺交換のUIカード
class NfcCard extends ConsumerStatefulWidget {
  const NfcCard({super.key});

  @override
  ConsumerState<NfcCard> createState() => _NfcCardState();
}

class _NfcCardState extends ConsumerState<NfcCard> {
  var _isNfcAvailable = false;
  var _isNfcActive = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  /// NFCが利用可能かチェック
  Future<void> _checkNfcAvailability() async {
    final nfcService = ref.read(nfcServiceProvider);
    final isAvailable = await nfcService.isNfcAvailable();
    if (mounted) {
      setState(() {
        _isNfcAvailable = isAvailable;
      });
    }
  }

  /// 自分の名刺をNFCで送信開始
  Future<void> _startNfcSending() async {
    if (!_isNfcAvailable) {
      await Fluttertoast.showToast(
        msg: 'NFCが利用できません',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14,
      );
      return;
    }

    setState(() {
      _isNfcActive = true;
    });

    try {
      final authState = ref.read(authStateProvider);
      await authState.when(
        data: (user) async {
          if (user != null) {
            final profile = await ref.read(firebaseProfileProvider.future);
            if (profile != null) {
              final nfcService = ref.read(nfcServiceProvider);
              await nfcService.startNfcTagWriting(profile);
              await Fluttertoast.showToast(
                msg: 'NFC送信開始: ${profile.name}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                textColor: Colors.white,
                fontSize: 14,
              );
            } else {
              await Fluttertoast.showToast(
                msg: 'プロフィールが見つかりません',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                textColor: Colors.white,
                fontSize: 14,
              );
            }
          } else {
            await Fluttertoast.showToast(
              msg: 'ログインが必要です',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black.withValues(alpha: 0.8),
              textColor: Colors.white,
              fontSize: 14,
            );
          }
        },
        loading: () async {
          await Fluttertoast.showToast(
            msg: '認証中です...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withValues(alpha: 0.8),
            textColor: Colors.white,
            fontSize: 14,
          );
        },
        error: (Object error, StackTrace stack) async {
          await Fluttertoast.showToast(
            msg: '認証エラー: $error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withValues(alpha: 0.8),
            textColor: Colors.white,
            fontSize: 14,
          );
        },
      );
    } on Exception catch (e) {
      await Fluttertoast.showToast(
        msg: 'NFC送信エラー: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNfcActive = false;
        });
      }
    }
  }

  /// NFCから名刺を受信開始
  Future<void> _startNfcReceiving() async {
    if (!_isNfcAvailable) {
      await Fluttertoast.showToast(
        msg: 'NFCが利用できません',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14,
      );
      return;
    }

    setState(() {
      _isNfcActive = true;
    });

    try {
      final nfcService = ref.read(nfcServiceProvider);
      final receivedProfile = await nfcService.startNfcTagReading();

      if (receivedProfile != null) {
        // 受信した名刺を連絡先に追加
        final addUc = await ref.read(addContactUseCaseProvider.future);
        final contact = Contact(
          id: receivedProfile.userId,
          name: receivedProfile.name,
          userId: receivedProfile.userId,
          bio: receivedProfile.message,
          githubUsername: receivedProfile.github,
          skills: receivedProfile.skills,
          avatarUrl: receivedProfile.avatar,
        );

        final ok = await addUc(contact);
        if (ok) {
          await Fluttertoast.showToast(
            msg: '名刺を受信しました: ${receivedProfile.name}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withValues(alpha: 0.8),
            textColor: Colors.white,
            fontSize: 14,
          );
          ref.invalidate(contactsProvider);
        } else {
          await Fluttertoast.showToast(
            msg: 'すでに追加済みです',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withValues(alpha: 0.8),
            textColor: Colors.white,
            fontSize: 14,
          );
        }
      } else {
        await Fluttertoast.showToast(
          msg: '名刺の受信に失敗しました',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    } on Exception catch (e) {
      await Fluttertoast.showToast(
        msg: 'NFC受信エラー: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNfcActive = false;
        });
      }
    }
  }

  /// NFCセッションを停止
  Future<void> _stopNfcSession() async {
    final nfcService = ref.read(nfcServiceProvider);
    await nfcService.stopNfcSession();
    setState(() {
      _isNfcActive = false;
    });
    await Fluttertoast.showToast(
      msg: 'NFCセッションを停止しました',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isNfcAvailable ? Icons.nfc : Icons.nfc_outlined,
                  color: _isNfcAvailable ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'NFC名刺交換',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (!_isNfcAvailable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NFC未対応',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isNfcAvailable) ...[
              Text(
                Platform.isIOS
                    ? 'NFCを使って名刺を送信・受信できます\n（iOS: デバイスを近づけてください）'
                    : 'NFCを使って名刺を送信・受信できます',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GoldGradientButton(
                      icon: Icons.nfc,
                      label: '名刺を送信',
                      onPressed: _isNfcActive ? null : _startNfcSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GoldGradientButton(
                      icon: Icons.nfc_outlined,
                      label: '名刺を受信',
                      onPressed: _isNfcActive ? null : _startNfcReceiving,
                    ),
                  ),
                ],
              ),
              if (_isNfcActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NFC待機中...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _stopNfcSession,
                      child: const Text('停止'),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Text(
                'このデバイスはNFCに対応していません',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
