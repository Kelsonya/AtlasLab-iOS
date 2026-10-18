# Atlas Lab X — iOS Reverse Engineering Proving Ground

**A substantial, multi-binary iOS application created specifically for authorized binary research.**

- SwiftUI interface with **5 tabs**, **24 real readable modules**, working bookmarks, progress and statistics, text analysis, StoreKit 2 read-only inspection, and diagnostic audit trails.
- **Three ARM64 Mach-O binaries** in the unsigned IPA: main `AtlasLabX`, dynamic `AtlasPolicy.framework`, and dynamic `AtlasSignals.framework`.
- The app's main executable contains real C functions controlling a local grant, rights bits, expiry and integrity seal. The Swift policy framework evaluates independent conditions and checks signed server grants.
- Ed25519 signature verification on device; demo private key is kept in the `server/` source folder (never embedded in the iOS app). A Python HTTP server issues fresh, nonce-bound signed rights and controls tier/status/expiration. Signed offline fixtures work when no backend is running.
- Four reproducible accounts: expired PRO, active lifetime, suspended PRO, and active BASIC.
- Local, signed and hybrid authorization modes. StoreKit 2 is an *independent, read-only inspector* and **not an integrated App Store subscription checkout**.
- Instrumentation scripts for IDA Pro 9.x and plain Python. A GitHub Actions workflow builds an unsigned iPhone IPA from Windows.

> This is a purpose-built security laboratory. It is more realistic than a single Boolean flag, but it is not a deployed commercial app. The training signing key is included only to make the challenge reproducible. Do not reuse the key or permissive HTTP settings in a real product.

## Start here

1. Read [docs/START_WINDOWS_RU.md](docs/START_WINDOWS_RU.md).
2. Upload **the contents of this directory** to the existing GitHub repository, preserving `.github/workflows/build-ios.yml`.
3. Run GitHub **Actions → Atlas Lab X — build unsigned IPA**.
4. Download artifact `AtlasLabX-iOS-binaries`. Inside: `AtlasLabX-UNSIGNED.ipa` and `MachO/AtlasLabX-main-arm64`, `AtlasPolicy-arm64`, `AtlasSignals-arm64`.
5. Open each Mach-O separately in IDA Pro 9.2. Do not expect all authorization decisions to be in the main executable.

The output is an **unsigned** IPA. iOS installation requires signing the app **and its embedded frameworks** with a valid certificate/profile.

## Local tests (Windows / Linux)

```sh
python -m pip install cryptography PyYAML
python -m unittest discover -s tests -v
```

On macOS/Linux with clang, native code smoke tests:

```sh
clang -std=c11 -O2 App/GateCore/NativeGate.c tests/native_smoke.c -o native_smoke
./native_smoke
```

## Optional real server

```sh
python -m pip install cryptography PyYAML
python server/app.py --host 0.0.0.0 --port 8765
```

Your phone should be on the same trusted LAN. In the app, open `Лаборатория` and enter `http://YOUR_PC_LAN_IP:8765`. The server uses `server/accounts.json` as its source of truth. The server is deliberately a minimal demo, without production authentication, TLS, or rate limiting: **do not expose it to the public Internet**. The app's ATS exception permits local HTTP for learning only.

## What to research

1. Is the expired 2023 date stored as plaintext, an immediate integer, or something else?
2. Where does the C integrity seal come from? How does tampering alter the outcome?
3. When does the app require both local and signed grants?
4. Why can a client modify locally computed access, yet cannot make a forged Ed25519 signature validate?
5. Does the lifetime profile automatically unlock every feature, or are there per-feature rules?
6. Can one collect cross-module calls and prove which of the three binaries decides access?

See [docs/REVERSE_CHALLENGE_RU.md](docs/REVERSE_CHALLENGE_RU.md).
