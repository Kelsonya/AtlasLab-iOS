# Atlas Lab — iOS Reverse Engineering practice app

A **real SwiftUI iOS app source project**, purpose-built for learning binary analysis with IDA Pro 9.2.

**Important:** The bundled license is a deliberately vulnerable **local mock**. It is NOT an App Store subscription, no purchases are made, and the "server" mode is only a JSON fixture bundled with the application (no network server). Do not confuse this lab with real StoreKit/production entitlement checking.

## What is inside?

- 4 tabs: home, 8-lecture library, gated analytics, account/subscription inspector.
- 3 accounts: expired Pro (default), basic, suspended Pro.
- 2 entitlement engines: locally compiled ARM64/C check and a simulated server JSON response.
- Diagnostics show which conditions pass/fail.
- Optional real StoreKit 2 **read-only** probe (no configured products and no purchase calls).
- A deliberately searchable training marker and a 2023 expiry date in the Mach-O file.

## Build on Windows (using GitHub Actions)

Xcode builds the iPhone app, and Xcode requires macOS. A Windows computer can upload the source to GitHub and use the included workflow (`.github/workflows/build-ios.yml`) to compile an **unsigned** iPhone IPA on a GitHub-hosted macOS runner.

1. Extract the ZIP to a regular folder, e.g. `C:\AtlasLab`.
2. Make a new GitHub repository, upload **all repository files preserving the directory structure**, including the hidden `.github/workflows/build-ios.yml`. Git for Windows / GitHub Desktop is easier than dragging files separately in the web UI.
3. In GitHub open **Actions** > **Build unsigned iOS training IPA** > **Run workflow**. A push to `main` also starts it automatically.
4. Wait for the build. At the end of the run download **AtlasLab-iOS-lab-files** from **Artifacts**.
5. Unzip that artifact. It contains **AtlasLab-UNSIGNED.ipa** and **AtlasLab-arm64-MachO**.
6. Open `AtlasLab-arm64-MachO` in IDA to inspect the binary, or sign `AtlasLab-UNSIGNED.ipa` using **your own valid iOS developer certificate** in ESign, then install on your iPhone.

A build by GitHub Actions is not guaranteed until the workflow actually runs. If it fails, use the attached build log. GitHub account/runners/usage policies and signing eligibility may affect availability.

### Alternative: macOS with Xcode

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project AtlasLab.xcodeproj -scheme AtlasLab -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath "$PWD/DerivedData" CODE_SIGNING_ALLOWED=NO build
```

### Precompiled practice binary for IDA

`bin/LicenseCore-arm64.o` is a Mach-O **object** for ARM64 iOS built from `App/LicenseCore/LicenseCore.c` without Xcode. It is NOT an installable app but is immediately usable for strings, xrefs and code navigation in IDA.

## Training objective

The LOCAL seed is `2023-12-31T23:59:59Z`. That is expired. Changing just the four year bytes to `2099` in your own lab binary changes the outcome for the default Pro profile (after the modified binary is assembled into the app and properly signed).

The simulated-server mode uses `RemoteFixture.json` (with `active: false`), so modifying the LOCAL date is **not** enough in that mode. It makes the client/server distinction visible, but the fixture is not a real server and does not provide actual security.

Start with `docs/LESSON_01.md`. Source code is intentionally included so that you can check every claim and compare decompiled code with original implementation.
