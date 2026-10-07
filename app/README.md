# ParaliSetu — Android App (Flutter)

**Stack:** Flutter (Dart) · Firebase Auth (Phone OTP) · Provider/Riverpod

## Day 1 setup (Oct 8)

Run the following in this directory to initialise the Flutter project:

```bash
flutter create --org in.paralisetu --project-name parali_setu .
```

Then add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # or riverpod
  dio: ^5.4.3               # HTTP client
  speech_to_text: ^6.6.2   # voice input
  google_maps_flutter: ^2.6.1
  geolocator: ^11.0.0
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0
  firebase_core: ^2.27.1
  firebase_auth: ^4.19.4
  intl: ^0.19.0
  flutter_rating_bar: ^4.0.1
```

**Key screens to build:**
1. Splash / OTP login
2. Language select (Hindi / Punjabi)
3. Voice intake (acres + harvest date)
4. 2-question form (variety, harvest method)
5. Estimate screen
6. Options / match screen (2-3 bundles)
7. Booking confirmation
8. Live pickup status
9. Weighbridge weight entry
10. Payment & impact screen
11. Satellite verification result
12. Rating screen

> Read SPEC.md and docs/AGENT_RULES.md before writing any code.
> Adapted patterns from Farmlink (Flutter) with owner permission.
> See docs/COPIED_CODE.md for a full log of reused code.
