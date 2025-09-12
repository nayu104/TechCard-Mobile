f# TechCard Mobile

名刺交換アプリケーション。QRコード、NFC、位置情報マッピング機能を搭載。

## 機能

- 名刺の作成・管理
- QRコードによる名刺交換
- NFCによる名刺交換
- Google Maps による交換地点のマッピング
- Firebase によるデータ同期

## セットアップ

### 1. 依存関係のインストール

```bash
fvm flutter pub get
```

### 2. Google Maps API キーの設定

1. [Google Cloud Console](https://console.cloud.google.com/)でプロジェクトを作成
2. Maps SDK for Android と Maps SDK for iOS を有効化
3. API キーを作成
4. 以下のいずれかの方法でAPIキーを設定：

#### ローカル開発用
`android/local.properties` ファイルを編集：
```properties
WEB_GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
```

#### GitHub Actions用
GitHubのリポジトリシークレットに `WEB_GOOGLE_MAPS_API_KEY` を設定

### 3. Firebase の設定

1. Firebase プロジェクトを作成
2. `google-services.json` (Android) と `GoogleService-Info.plist` (iOS) を配置
3. GitHubのリポジトリシークレットに `FIREBASE_TOKEN` を設定

### 4. アプリの実行

```bash
fvm flutter run
```

## 権限

- **位置情報**: 名刺交換地点の記録に使用
- **NFC**: 名刺データの送受信に使用
- **カメラ**: QRコードの読み取りに使用（オプション）

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
 