# FlutterでiOS向けNFC名刺交換機能を実装する方法

## 概要

FlutterアプリでiOSデバイス向けのNFC（Near Field Communication）名刺交換機能を実装する方法を解説します。iOSではAndroidとは異なる制限や要件があるため、それらに対応した実装方法を紹介します。

## iOSでのNFC制限事項

### 1. 対応デバイス
- **iPhone 7以降**（iOS 11以降）
- **iPhone SE (第2世代)以降**
- **iPad Pro (11インチ) (第1世代)以降**
- **iPad Pro (12.9インチ) (第3世代)以降**

### 2. 機能制限
- **読み取り専用**: iOSではNFCタグへの書き込みは制限されている
- **アプリ内でのみ動作**: バックグラウンドでのNFC読み取りは不可
- **ユーザー操作が必要**: タップしてNFCを有効化する必要がある

## 実装手順

### 1. iOS権限設定

#### Info.plistの設定
```xml
<!-- ios/Runner/Info.plist -->
<key>NFCReaderUsageDescription</key>
<string>名刺データを送受信するためにNFCを使用します。</string>
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
    <string>NDEF</string>
</array>
```

### 2. 依存関係

#### pubspec.yaml
```yaml
dependencies:
  nfc_manager: ^3.3.0  # iOS/Android両対応
```

### 3. iOS対応NFCサービス

```dart
// lib/infrastructure/services/nfc_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  /// NFCが利用可能かチェック（iOS対応）
  Future<bool> isNfcAvailable() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    
    // iOSの場合、追加のチェック
    if (Platform.isIOS) {
      // iOS 11以降でNFCが利用可能
      return isAvailable;
    }
    
    return isAvailable;
  }

  /// iOS用: NFCタグから名刺データを読み取り
  Future<MyProfile?> startNfcTagReading() async {
    MyProfile? profile;
    
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            final ndefMessage = await ndef.read();
            final record = ndefMessage.records.first;
            
            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
              final data = utf8.decode(record.payload);
              final profileJson = jsonDecode(data) as Map<String, dynamic>;
              profile = MyProfile.fromJson(profileJson);
            }
          }
        } on Exception catch (e) {
          // エラーハンドリング
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );
    
    return profile;
  }

  /// iOS用: 名刺データを表示用QRコードとして生成
  /// （iOSではNFC書き込みが制限されているため）
  Future<String> generateNfcQrCode(MyProfile profile) async {
    final profileJson = profile.toJson();
    final data = jsonEncode(profileJson);
    return data; // QRコード生成用のデータを返す
  }
}
```

### 4. iOS対応UI実装

```dart
// lib/presentation/widgets/exchange/nfc_card.dart
import 'dart:io';

class NfcCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<NfcCard> createState() => _NfcCardState();
}

class _NfcCardState extends ConsumerState<NfcCard> {
  var _isNfcAvailable = false;
  var _isNfcActive = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プラットフォーム別の説明文
            Text(
              Platform.isIOS 
                  ? 'NFCを使って名刺を受信できます\n（iOS: デバイスを近づけてください）'
                  : 'NFCを使って名刺を送信・受信できます',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            if (_isNfcAvailable) ...[
              const SizedBox(height: 16),
              
              // iOS用: 受信のみのボタン
              if (Platform.isIOS) ...[
                GoldGradientButton(
                  icon: Icons.nfc_outlined,
                  label: '名刺を受信',
                  onPressed: _isNfcActive ? null : _startNfcReceiving,
                ),
                const SizedBox(height: 8),
                Text(
                  '※ iOSではNFC書き込みが制限されているため、\n送信はQRコードを使用してください',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ] else ...[
                // Android用: 送信・受信両方
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
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// NFCから名刺を受信（iOS/Android共通）
  Future<void> _startNfcReceiving() async {
    if (!_isNfcAvailable) {
      await Fluttertoast.showToast(msg: 'NFCが利用できません');
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
              msg: '名刺を受信しました: ${receivedProfile.name}');
          ref.invalidate(contactsProvider);
        }
      }
    } on Exception catch (e) {
      await Fluttertoast.showToast(msg: 'NFC受信エラー: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isNfcActive = false;
        });
      }
    }
  }
}
```

## iOS特有の考慮事項

### 1. ユーザビリティ
- **明確な指示**: ユーザーにデバイスを近づけるよう指示
- **視覚的フィードバック**: NFC待機状態を明確に表示
- **エラーメッセージ**: iOS特有の制限を説明

### 2. 代替手段の提供
```dart
// iOSではNFC書き込みが制限されているため、QRコードを併用
if (Platform.isIOS) {
  return Row(
    children: [
      Expanded(
        child: GoldGradientButton(
          icon: Icons.qr_code,
          label: 'QRコードで送信',
          onPressed: _showQrCode,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: GoldGradientButton(
          icon: Icons.nfc_outlined,
          label: 'NFCで受信',
          onPressed: _startNfcReceiving,
        ),
      ),
    ],
  );
}
```

### 3. デバイス対応チェック
```dart
Future<bool> _checkNfcSupport() async {
  if (Platform.isIOS) {
    // iOS 11以降のチェック
    final version = await DeviceInfoPlugin().iosInfo;
    final majorVersion = int.parse(version.systemVersion.split('.').first);
    return majorVersion >= 11;
  }
  return true;
}
```

## テスト方法

### 1. 実機テスト
- **iPhone 7以降**でテスト
- **NFCタグ**を使用して読み取りテスト
- **異なるiOSバージョン**でテスト

### 2. シミュレータでの制限
- iOSシミュレータではNFC機能は利用不可
- 実機でのテストが必須

## まとめ

iOSでのNFC実装では以下の点に注意が必要です：

- ✅ **読み取り専用**: 書き込みは制限されている
- ✅ **デバイス対応**: iPhone 7以降が必要
- ✅ **ユーザー操作**: タップしてNFCを有効化
- ✅ **代替手段**: QRコードとの併用を検討
- ✅ **明確なUI**: プラットフォーム別の説明文

iOSの制限を理解し、適切な代替手段を提供することで、両プラットフォームで使いやすい名刺交換機能を実現できます。

## 参考リンク

- [iOS NFC Documentation](https://developer.apple.com/documentation/corenfc)
- [nfc_manager package](https://pub.dev/packages/nfc_manager)
- [iOS NFC Reader Session](https://developer.apple.com/documentation/corenfc/nfcreadersession)
