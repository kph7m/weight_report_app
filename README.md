# Weight Report App

Flutter（stable channel）のAndroid向け体重管理アプリです。

## 機能

- Material 3 UI
- Riverpodによる状態管理
- Isarによるローカル永続化
- 今日の体重入力
- 体重履歴一覧
- 直近7日平均表示
- 目標75kgまでの進捗表示
- GitHub ActionsによるAPKビルド

## 開発

```bash
flutter pub get
flutter test
flutter build apk --release
```

Codex push test

## Android ReleaseビルドとFirebase App Distribution

GitHub Actionsでは、Firebase App Distributionへ `build/app/outputs/flutter-apk/app-release.apk` を配布します。Debug APKでは署名が異なるため、Firebaseからインストールしたアプリを次回アップデートできません。Release APKは `android/key.properties` に定義した同じkeystoreで署名してください。

### 初回だけkeystoreを作成する

初回だけ、開発端末でアップロード用keystoreを作成します。パスワードとaliasは安全に保管してください。

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

ローカルでReleaseビルドを確認する場合は、`android/upload-keystore.jks` にkeystoreを置き、`android/key.properties` を作成します。

```properties
storePassword=作成時のstore password
keyPassword=作成時のkey password
keyAlias=upload
storeFile=upload-keystore.jks
```

`android/key.properties` と `android/upload-keystore.jks` は秘密情報のためGitにコミットしません。

### GitHub Secrets登録方法

GitHub repositoryの **Settings > Secrets and variables > Actions** に以下を登録します。

| Secret名 | 内容 |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `upload-keystore.jks` をBase64化した文字列 |
| `ANDROID_KEY_PROPERTIES` | `android/key.properties` の内容 |
| `GCP_SA_KEY` | Firebase App DistributionにアップロードできるService Account JSON |
| `FIREBASE_APP_ID` | Firebase AndroidアプリID |

`ANDROID_KEYSTORE_BASE64` は以下のように作成できます。

```bash
base64 -w 0 upload-keystore.jks
```

macOSなど `-w` が使えない環境では以下を使います。

```bash
base64 upload-keystore.jks | tr -d '\n'
```

`ANDROID_KEY_PROPERTIES` には以下の4項目を改行込みで登録します。

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

### versionCodeについて

Flutterでは `pubspec.yaml` の `version: x.y.z+n` の `+n` がAndroidの `versionCode` として使われます。このプロジェクトの `android/app/build.gradle` は `versionCode flutter.versionCode` を参照しています。

Firebase App Distributionからインストール済みのアプリをアンインストールなしでアップデートするには、配布のたびに `pubspec.yaml` の `+n` を前回より大きい値に増やしてください。例: `version: 1.0.0+2`。
