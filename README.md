# LAME iOS Swift Reference – Derived Technical Reference (LGPL 2.1)

[![License: LGPL v2.1](https://img.shields.io/badge/License-LGPL%202.1-blue.svg)](https://opensource.org/licenses/LGPL-2.1)
[![Platform: iOS](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](#)
[![Language: Swift](https://img.shields.io/badge/language-Swift-orange.svg)](#)
[![Status: Technical Reference](https://img.shields.io/badge/status-Technical%20Reference-green.svg)](#)
[![Based on: LAME 3.100](https://img.shields.io/badge/based--on-LAME%203.100-blue.svg)](https://github.com/lameproject/lame)

---

## 🏁 Introduction / はじめに

**English**  
This repository provides a ready-to-use **technical reference** for iOS developers  
who want to integrate **MP3 encoding (libmp3lame)** into their **Swift** projects.  
It explains how to build and use LAME 3.100 as a **static XCFramework**, enabling WAV (PCM) → MP3 conversion directly from Swift.

**日本語**  
このリポジトリは、iOSアプリ開発者が **Swift** で **LAME (libmp3lame)** を利用し、  
**WAV (PCM) → MP3** 変換を実装するための **技術的参考実装** です。  
LAME 3.100 を **XCFramework** としてビルドし、Swiftから利用できる形にする手順を解説しています。

> ⚠️ Note: This repository is a **reference implementation**, not a ready-made library.  
> ⚠️ 注意: このリポジトリは **学習・技術検証用のリファレンス実装** です。  
> 商用利用や再配布の際は、LAME の LGPL 2.1 ライセンス条件に従ってください。

---

## ⚙️ Requirements / 必要環境

**English**  
- macOS with Xcode installed  
- Command Line Tools (can be installed with `xcode-select --install`)  
- Basic familiarity with Terminal commands

**日本語**  
- Xcode がインストールされた macOS  
- Command Line Tools（`xcode-select --install` でインストール可能）  
- ターミナル操作の基本的な知識

---

## 🚀 Quick Start / クイックスタート

**English**  
Follow these steps to clone the repository and build the XCFramework:  
**日本語**  
以下の手順でリポジトリをクローンし、XCFrameworkをビルドしてください。

```shell
git clone https://github.com/masaconm/lame-ios-swift-reference.git
cd lame-ios-swift-reference
bash Scripts/build_xcframework.sh
```

After running the script, `Frameworks/Lame.xcframework` will be generated.

スクリプト実行後、`Frameworks/Lame.xcframework` が生成されます。

> 📘 Why no prebuilt binary? / なぜビルド済みバイナリを含まないのか
> 
> To comply with LGPL 2.1 and ensure transparency, this project does **not include prebuilt binaries**.  
> Instead, users can **reproduce the exact build** themselves using the included script.
> 
> LGPL 2.1 のライセンスに従い、透明性を保つため、**ビルド済みバイナリは同梱していません**。  
> 付属のスクリプトを使えば、利用者自身が同一の成果物を再現できます。

---

## 🧱 Build & Reproduction — Full Steps / 生成手順

> This section shows **only the steps to generate the XCFramework**, from clone to output verification.  
> 以下は **XCFramework を生成するための手順のみ** をまとめたものです（クローン→生成→確認）。

---

## 0) Requirements / 必要環境
- **macOS + Xcode**（Command Line Tools を含む）  
  macOS with **Xcode + Command Line Tools** (`xcode-select --install`)
- `xcodebuild` が使えること（Terminalで `xcodebuild -version` で確認）  
  Make sure `xcodebuild` is available.

---

## 1) Clone the repository / リポジトリの取得
```shell
git clone https://github.com/masaconm/lame-ios-swift-reference.git
cd lame-ios-swift-reference
```

---

## 2) (Optional) Apply header patch / パッチ適用（任意）
If you want to inspect/apply the exact header changes:
```shell
# Example
# cd /tmp
# curl -L -o lame-3.100.tar.gz "https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download"
# tar xf lame-3.100.tar.gz && cd lame-3.100
# patch -p1 < /path/to/YourRepo/PATCHES/0001-swift-header-fixes.patch
```
- If you are using the pre-modified lame-3.100/ included in this repository, **you can skip this step**.
- ※ 本リポジトリの改修済み lame-3.100/ を使用する場合は **この手順は不要**。 
---

## 3) Place your modified LAME source / 改修済みソースの配置
> スクリプトは `lame-3.100/` をソースとして利用します。  
> The build script uses `lame-3.100/` as the source.

```shell
# If needed, copy your modified source here
# 必要に応じて、改修済み LAME ソースを配置
# cp -a "/path/to/your/lame-3.100/." "./lame-3.100/"
```

---

## 4) Ensure static libs exist OR build them / .a を用意（なければ生成）
The script expects the following files **(existing paths in this repo’s layout)**:

- Device (arm64):  
  `lame-3.100/build/ios/lib/libmp3lame.a`
- Simulator (arm64):  
  `lame-3.100/build/ios-sim/lib/libmp3lame.a`

### 4-1) If they already exist / 既にある場合
→ そのまま **Step 5** へ。

### 4-2) If simulator lib is missing / シミュレータ用が無い場合の最小生成例
```shell
cd lame-3.100
make distclean || true
rm -rf build/ios-sim

SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
./configure   --host=aarch64-apple-darwin   --disable-shared --enable-static   --disable-frontend   CC="xcrun -sdk iphonesimulator clang"   CFLAGS="-isysroot ${SDK_PATH} -arch arm64 -mios-simulator-version-min=13.0"   LDFLAGS="-isysroot ${SDK_PATH} -arch arm64 -mios-simulator-version-min=13.0"   --prefix=$(pwd)/build/ios-sim

make -j"$(sysctl -n hw.logicalcpu)"
make install
cd ..
```
> これで `lame-3.100/build/ios-sim/lib/libmp3lame.a` が生成されます。  
> The command creates `lame-3.100/build/ios-sim/lib/libmp3lame.a`.

### 4-3) If device lib is missing / 実機用が無い場合の最小生成例（参考）
（あなたの環境の生成スクリプトに合わせてください。以下は参考）
```shell
# Example only – align with your existing iOS device build process
# 例：既存の build-lame-ios.sh 等で arm64 iOS 用 libmp3lame.a を生成し、
# lame-3.100/build/ios/lib/libmp3lame.a に配置
```

---

## 5) Build the XCFramework / XCFramework の生成（重要）
**Yes, this step is required.**  
Run the following **from the repository root**.

```shell
cd lame-ios-swift-reference   # ← 念のため、リポジトリ直下へ戻る
bash Scripts/build_xcframework.sh
```

> これで `Frameworks/Lame.xcframework` が生成されます（デバイス＋シミュレータ両対応）。  
> This creates `Frameworks/Lame.xcframework` (device + simulator slices).

---

## 6) Verify output / 生成物の確認
```shell
ls -1 Frameworks/Lame.xcframework
# Expected:
# Info.plist
# ios-arm64
# ios-arm64-simulator

ls -1 Frameworks/Lame.xcframework/ios-arm64
# Expected: Headers/ , libmp3lame.a

ls -1 Frameworks/Lame.xcframework/ios-arm64/Headers
# Expected: lame.h (and public headers if any)
```

---

## Notes / 補足
- **Why no prebuilt binary?**  
  LGPL 2.1 の遵守・透明性・再現性のため、ビルド済みの成果物は同梱していません。  
  Anyone can reproduce the exact output via the script.
- **Common pitfalls**  
  - `bash: Scripts/build_xcframework.sh: No such file or directory`  
    → `cd lame-ios-swift-reference`（リポジトリ直下）で実行しているか確認  
  - `A library with the identifier 'ios-arm64' already exists`  
    → シミュレータにもデバイスと同じ `.a` を渡していないか確認（`ios-sim` は必ず **シミュレータ用**の .a）  
  - `header not found`  
    → Xcode 側で必要なら `$(SRCROOT)/Frameworks/Lame.xcframework/**/Headers` を Header Search Paths に追加

---

### まとめ / TL;DR
- **Step 5 の 2行は必須**：  
  ```shell
  cd lame-ios-swift-reference
  bash Scripts/build_xcframework.sh
  ```
- その前提として、`lame-3.100/build/ios/lib/libmp3lame.a` と  
  `lame-3.100/build/ios-sim/lib/libmp3lame.a` が存在していることを確認（無ければ Step 4 で作成）。

---

## 🧩 Integrating into Xcode / Xcodeへの組み込み

**English**  
1. Drag `Frameworks/Lame.xcframework` into your Xcode project.  
2. In Target → General → **Frameworks, Libraries, and Embedded Content**:  
   - Static XCFramework (`.a`): Select **Do Not Embed**  
   - Dynamic XCFramework (`.framework`): Select **Embed & Sign**  
3. Add to your Bridging Header:  
   ```objc
   #include "lame.h"
   ```
4. If needed, add this to your Header Search Paths:  
   ```
   $(SRCROOT)/Frameworks/Lame.xcframework/**/Headers
   ```

**日本語**  
1. `Frameworks/Lame.xcframework` を Xcode プロジェクトへドラッグ＆ドロップします。  
2. Target → General → **Frameworks, Libraries, and Embedded Content** で設定：  
   - 静的XCFramework（`.a`）: **Do Not Embed** を選択  
   - 動的XCFramework（`.framework`）: **Embed & Sign** を選択  
3. Bridging Header に以下を追加：  
   ```objc
   #include "lame.h"
   ```
4. 必要に応じて Header Search Paths に以下を追加：  
   ```
   $(SRCROOT)/Frameworks/Lame.xcframework/**/Headers
   ```

---

## ⚖️ License & Compliance / ライセンスと遵守事項

**English**  
- This project includes modified portions of **LAME 3.100**, distributed under the **LGPL 2.1** license.  
- You must include `COPYING.LGPL` with your app if you redistribute the library.  
- For simplicity, **dynamic linking** is recommended.  
  (Static linking requires allowing users to relink against a modified version.)

**日本語**  
- このプロジェクトには **LAME 3.100 (LGPL 2.1)** の改変部分が含まれています。  
- ライブラリをアプリとともに再配布する場合は、`COPYING.LGPL` を同梱してください。  
- LGPL遵守を簡略化するため、**動的リンク** を推奨します。  
  （静的リンクを行う場合は、ユーザーが改変版で再リンクできる手段を提供する必要があります。）

---

## 💬 Notes / 補足と免責

**English**  
- This repository is a **technical reference**, not an official LAME release.  
- No warranties are provided.  
- You can reproduce all artifacts locally using the included build script.

**日本語**  
- このリポジトリは **技術的参考実装** であり、LAME の公式配布物ではありません。  
- 保証は一切ありません。  
- 付属スクリプトを使えば、誰でも同じ成果物をローカルで再現できます。

---

## 🏷️ Credits / クレジット

Upstream LAME project © 1998–2017 LAME Developers  
Swift interoperability adaptation © 2025 masaconm

---

### English

This project is based on the open-source **LAME MP3 Encoder**,  
originally developed and maintained by the **LAME Developers** from 1998 to 2017.  
The original source code is distributed under the **GNU Lesser General Public License v2.1 (LGPL 2.1)**  
and can be found at the official repository below:

➡️ https://github.com/lameproject/lame  
➡️ https://lame.sourceforge.io/

We sincerely thank the LAME Developers and the open-source community  
for their long-term contribution to the MP3 encoding ecosystem.

---

### 日本語

このプロジェクトは、オープンソースの **LAME MP3 エンコーダ** に基づいています。  
LAME は **LAME Developers** により 1998 年から 2017 年にかけて開発・保守され、  
オリジナルのソースコードは **GNU LGPL 2.1** ライセンスのもとで配布されています。  
公式リポジトリは以下から参照できます。

➡️ https://github.com/lameproject/lame  
➡️ https://lame.sourceforge.io/

MP3 エンコーディング技術とオープンソースコミュニティへの  
長年にわたる貢献に対し、**LAME 開発者の皆様に深く感謝**いたします。

---

### Notes / 補足

- “1998–2017” reflects the active development period of the official LAME releases (latest: v3.100, October 2017).  
- The current repository is an independent Swift/iOS adaptation, and is **not affiliated with or endorsed by** the original LAME project.

