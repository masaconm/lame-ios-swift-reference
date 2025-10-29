# LAME iOS Swift Reference – Derived Technical Reference (LGPL 2.1)

[![License: LGPL v2.1](https://img.shields.io/badge/License-LGPL%202.1-blue.svg)](https://opensource.org/licenses/LGPL-2.1)
[![Platform: iOS](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](#)
[![Language: Swift](https://img.shields.io/badge/language-Swift-orange.svg)](#)
[![Status: Technical Reference](https://img.shields.io/badge/status-Technical%20Reference-green.svg)](#)
[![Based on: LAME 3.100](https://img.shields.io/badge/based--on-LAME%203.100-blue.svg)](https://github.com/lameproject/lame)

This repository provides a **derived, technical reference implementation**  
of **LAME 3.100** for integrating **MP3 encoding (libmp3lame)** into **Swift / iOS** applications.  
It demonstrates how to adapt and build the original LAME source as a **static XCFramework**,  
making it callable from Swift for WAV (PCM) → MP3 conversion.

このリポジトリは、**LAME 3.100** を基に、  
**Swift / iOS** から MP3 エンコード（libmp3lame）を利用可能にするための  
**技術的参考実装（Derived Technical Reference）** です。  
WAV(PCM) → MP3 変換を行うために、オリジナルの LAME ソースを  
**静的XCFramework** としてビルドする手順を示しています。

---

- Upstream: [https://github.com/lameproject/lame](https://github.com/lameproject/lame)  
- License: **LGPL 2.1** (see `COPYING.LGPL`)  
- Purpose: Technical reference on LAME + Swift integration for iOS  
- Maintainer: [masaconm](https://github.com/masaconm)

---

## 📂 Repository Structure / フォルダ構成

```
lame-ios-swift-reference/
├─ lame-3.100/                  # 改変後ソース（ヘッダ修正済み） / Modified LAME source
│  └─ build/
│     ├─ ios/lib/libmp3lame.a       # iOS実機用 / Device build
│     └─ ios-sim/lib/libmp3lame.a   # iOSシミュレータ用 / Simulator build
├─ PATCHES/
│  └─ 0001-swift-header-fixes.patch # Swift連携用パッチ / Header fix patch
├─ Scripts/
│  └─ build_xcframework.sh          # XCFramework生成スクリプト / Build script
├─ Frameworks/
│  └─ Lame.xcframework/             # Device + Simulator ビルド成果物 / XCFramework output
├─ COPYING.LGPL                     # LAMEライセンス原文 / License text
├─ LICENSE_NOTICE.md                # LGPL要約・クレジット / License summary
├─ LICENSE                          # あなたの著作権表記 / Personal copyright statement
└─ README.md                        # このファイル / This file
```

---

## 🧱 Build & Reproduction / 再現手順

```bash
# 0) Place your patch in PATCHES/
#    例: /Users/.../LAME_LT/PATCHES/0001-swift-header-fixes.patch

# 1) Apply patch to original LAME (optional)
cd /tmp
curl -L -o lame-3.100.tar.gz "https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download"
tar xf lame-3.100.tar.gz && cd lame-3.100
patch -p1 < /path/to/YourRepo/PATCHES/0001-swift-header-fixes.patch

# 2) Copy your modified source
cp -a "/Users/YourName/Desktop/LAME_LT/lame-3.100/." /path/to/YourRepo/lame-3.100/

# 3) Build XCFramework (static)
cd /path/to/YourRepo
bash Scripts/build_xcframework.sh
```

---

## 🧩 Xcode Integration / Xcodeへの組み込み

1. Drag & drop `Frameworks/Lame.xcframework` into your Xcode project.  
   → `Frameworks/Lame.xcframework` を Xcode プロジェクトへドラッグ＆ドロップ  
2. **Target > General > Frameworks, Libraries, and Embedded Content**  
   - Static XCFramework (`.a`): **Do Not Embed**  
   - Dynamic XCFramework (`.framework`): **Embed & Sign**  
3. **Bridging Header**
   ```objc
   #include "lame.h"
   ```
4. **Header Search Paths** (if needed)  
   **Header Search Paths**（必要時）  
   ```
   $(SRCROOT)/Frameworks/Lame.xcframework/**/Headers
   ```
5. Clean Build Folder → Build ✅

---

## ⚖️ License Notice / ライセンス注意

- LAME is distributed under **LGPL 2.1**. Attribution and inclusion of `COPYING.LGPL` are mandatory.  
- When distributing apps, **dynamic linking is recommended** for easier LGPL compliance.  
- If statically linked, provide users with a way to **relink** against a modified version.  

LAME は **LGPL 2.1** に基づいて配布されています。  
クレジットの明示とライセンス原文の同梱が必要です。  
アプリ配布時は **動的リンク推奨**、静的リンクを行う場合はユーザーが改変版で再リンクできるようにしてください。

---

## 🧠 Dynamic Framework Option / 動的Frameworkで配布する場合

To distribute as a dynamic framework, create a new Xcode **Framework (Dynamic)** target linking `libmp3lame.a`:

```bash
xcodebuild -create-xcframework   -framework path/to/LameDynamic.framework   -output Frameworks/Lame.xcframework
```

Including this regeneration process in your README simplifies LGPL compliance.

Xcodeで **Dynamic Framework** ターゲットを作成し、`libmp3lame.a` をリンクしてXCFrameworkを生成します。  
この再生成手順をREADMEに記載しておくことで、LGPL準拠が容易になります。

---

## 🏷️ Credits / クレジット

- Upstream LAME project © 1998–2025 [LAME Developers](https://lame.sourceforge.io/)  
- Swift interoperability adaptation © 2025 [masaconm](https://github.com/masaconm)

This repository is provided **for educational and reference purposes only**.  
It is **not an official LAME distribution**.  
本リポジトリは教育および参考目的で提供されるものであり、LAME公式配布物ではありません。
