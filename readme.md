# SwiftUIのiOSアプリをMac以外でビルドしたい

## 必要なもの

- LinuxまたはWSL
  - Swift (>=6.0)
  - zip
  - plistutil (libplist-utils)

## あったらいいもの

- DevContainer
- (iOSのSDKを自分でビルドする場合)
  - [homebrew](https://brew.sh/ja/)
  - [unxip](https://formulae.brew.sh/formula/unxip)


## 0. 事前準備
[kabiroberai/swift-sdk-darwin](https://github.com/kabiroberai/swift-sdk-darwin)のスクリプトを利用してiOS用のSDKをビルドする。

基本的には上のrepoにあるとおりに作業したらいい。

1. `Xcode <version>.xip`を[Xcode](https://developer.apple.com/download/all/?q=Xcode)からダウンロード
2. unxipで`Xcode <version>.xip`を展開
3. [kabiroberai/swift-sdk-darwin](https://github.com/kabiroberai/swift-sdk-darwin)をクローン
4. `./build.sh Xcode.app/Contents/Developer` を実行
5. `swift-sdk-darwin/output`に`darwin-linux-x86_64.artifactbundle.zip`, `darwin-linux-x86_64.artifactbundle.zip.sha256`ができているのでコピーしておく。

2.と4.でかなり時間がかかるので、ビルド済みSDKも[ここ](https://github.com/fkunn1326/wsl-ipa-sample/releases/tag/prebuilt)に置いておく。

## 1. 環境構築

以下のコマンドで事前に取得したビルド済みSDKをインストールする
```bash
swift sdk install darwin-linux-x86_64.artifactbundle.zip
```

## 2. プロジェクトの作成

新しいフォルダーを作成し、その中でSwift Projectを初期化する。
```bash
swift package init --type executable
```
lspが動作するように、ワークスペースのルートに `.sourcekit-lsp/config.json`を作成して以下のように書く

```json
// .sourcekit-lsp/config.json
{
    "swiftPM": {
        "swiftSDK": "arm64-apple-ios"
    }
}
```
`main.swift`を`mainApp.swift`など違う名前に変えて、[sampleApp.swift](https://github.com/fkunn1326/wsl-ipa-sample/blob/prebuilt/Sources/sample/sampleApp.swift)を参考に編集し、以下のコマンドでビルドする。
```bash
swift build --swift-sdk arm64-apple-ios
```

## 3. ipaの作成

2.の段階で`.build/{debug/release}`に生成されるのはただの実行ファイルなので、これをipaにバンドルする必要がある。
ipaの実体はただの`.zip`なので、以下のようなフォルダ構成にして、zip化したらよい。
```
/
└─ Payload
      └─ XXX.app
            ├─ AppIconXXxXX.png
            └─ Info.plist
```
[build.sh](https://github.com/fkunn1326/wsl-ipa-sample/blob/master/build.sh)や[Info.plist](https://github.com/fkunn1326/wsl-ipa-sample/blob/master/assets/Info.plist)を参考にして、いろいろやったらいい
あとはそれを`.ipa`に名前を変更して、AltStoreやLiveContainerなど好きな方法で実機にいれたらいい。

## 4. トラブルシューティング

- `xxxx is only available in iOS X.0 or newer`

`Package.swift`を編集して

```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sample",
    platforms: [
        .iOS(.v13), // ここを適切なバージョンにする
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "sample",
            targets: ["sample"]),
    ],
// 続く...
```