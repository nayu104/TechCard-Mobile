// NFC機能を提供するサービス
// 名刺データの送信・受信をNFCで行う
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../domain/models.dart';

/// NFC機能を提供するサービス
class NfcService {
  /// NFCが利用可能かチェック
  Future<bool> isNfcAvailable() async {
    final isAvailable = await NfcManager.instance.isAvailable();

    // iOSの場合、追加のチェック
    if (Platform.isIOS) {
      // iOS 11以降でNFCが利用可能
      return isAvailable;
    }

    return isAvailable;
  }

  /// 自分の名刺データをNFCで送信
  /// 相手のデバイスがNFCタグを読み取った時に呼ばれる
  Future<void> startNfcTagWriting(MyProfile profile) async {
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // 名刺データをJSONに変換
          final profileJson = profile.toJson();
          final data = jsonEncode(profileJson);

          // NDEFレコードを作成
          final ndefRecord = NdefRecord.createText(data);
          final ndefMessage = NdefMessage([ndefRecord]);

          // NFCタグに書き込み
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            await ndef.write(ndefMessage);
            if (kDebugMode) {
              print('NFC書き込み完了: ${profile.name}');
            }
          }
        } on Exception catch (e) {
          if (kDebugMode) {
            print('NFC書き込みエラー: $e');
          }
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );
  }

  /// NFCタグから名刺データを読み取り
  /// 相手のデバイスがNFCタグを送信した時に呼ばれる
  Future<MyProfile?> startNfcTagReading() async {
    MyProfile? profile;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // NDEFレコードを読み取り
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            final ndefMessage = await ndef.read();
            final record = ndefMessage.records.first;

            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
              final data = utf8.decode(record.payload);
              final profileJson = jsonDecode(data) as Map<String, dynamic>;
              profile = MyProfile.fromJson(profileJson);

              if (kDebugMode) {
                print('NFC読み取り完了: ${profile?.name}');
              }
            }
          }
        } on Exception catch (e) {
          if (kDebugMode) {
            print('NFC読み取りエラー: $e');
          }
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );

    return profile;
  }

  /// NFCセッションを停止
  Future<void> stopNfcSession() async {
    await NfcManager.instance.stopSession();
  }
}
