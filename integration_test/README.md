# Integration tests

Phase 01 includes `app_smoke_test.dart`, which exercises the real app widget tree through its startup route, splash transition, foundation screen and AMOLED theme preview.

Flutter CI provisions an Android API 35 emulator and runs:

```sh
flutter test integration_test
```

Add product-flow integration tests in their owning phases. Use isolated data and deterministic fixtures. Physical-device and iOS simulator/device validation remain separate gates; emulator success does not replace them.
