# Verification record

The following checks are available in the supplied source archive:

- Python unit tests check signed grants, signature tampering, Ed25519 key length.
- Native C smoke test checks expired/active/suspended profiles and integrity seal invalidation after a modified expiration.
- The AtlasPolicy models and rule engine type-check using Swift on Linux.
- Swift syntax is parsed with `swiftc -frontend -parse`.
- JSON/YAML/plist parsing is checked with Python.

**Limitation:** Full SwiftUI/CryptoKit/StoreKit compilation and installation require Xcode/macOS; they were **not** possible in the Linux build environment used to package the sources. The included GitHub Actions workflow is the first real iOS compilation check. If the Xcode compiler finds a problem, use the uploaded build log to fix it; never treat a green non-Xcode unit test as proof that the IPA compiles.
