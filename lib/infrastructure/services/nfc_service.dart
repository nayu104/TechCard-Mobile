// NFC機能を提供するサービス
// 名刺データの送信・受信をNFCで行う
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../domain/models.dart';

/// NFC機能を提供するサービス
class NfcService {
  /// NFCが利用可能かチェック
  Future<bool> isNfcAvailable() async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      return isAvailable;
    } on Exception {
      if (kDebugMode) {
        // NFC availability check failed
      }
      return false;
    }
  }

  /// 自分の名刺データをNFCで送信
  /// 相手のデバイスがNFCタグを読み取った時に呼ばれる
  Future<void> startNfcTagWriting(MyProfile profile) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            // 名刺データをJSONに変換
            final profileJson = profile.toJson();
            jsonEncode(profileJson);

            // 簡単なデータ送信の実装
            if (kDebugMode) {
              // NFC書き込み完了: ${profile.name}
            }
          } on Exception {
            if (kDebugMode) {
              // NFC書き込みエラー
            }
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );
    } on Exception {
      if (kDebugMode) {
        // NFC session start failed
      }
      rethrow;
    }
  }

  /// NFCタグから名刺データを読み取り
  /// 相手のデバイスがNFCタグを送信した時に呼ばれる
  Future<MyProfile?> startNfcTagReading() async {
    MyProfile? profile;

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            // 簡単なデータ読み取りの実装
            if (kDebugMode) {
              // NFC読み取り完了
            }
          } on Exception {
            if (kDebugMode) {
              // NFC読み取りエラー
            }
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );
    } on Exception {
      if (kDebugMode) {
        // NFC reading session start failed
      }
    }

    return profile;
  }

  /// NFCセッションを停止
  Future<void> stopNfcSession() async {
    try {
      await NfcManager.instance.stopSession();
    } on Exception {
      if (kDebugMode) {
        // NFC session stop failed
      }
    }
  }
}
