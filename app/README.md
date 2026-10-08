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

---

## Building the APK

### 1. Configure the API Base URL
The backend base URL is injected at build time via `--dart-define`:
```bash
# Pointing to your deployed cloud backend:
flutter build apk --dart-define=API_BASE_URL=https://your-deployed-backend-url.com

# For local development with emulator:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# For local testing on a physical phone connected via USB:
# First run: adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### 2. Build Commands
- **Debug APK** (allows cleartext HTTP and includes demo mode OTP hints):
  ```bash
  flutter build apk --debug --dart-define=API_BASE_URL=https://your-deployed-backend-url.com
  ```
  Output path: `build/app/outputs/flutter-apk/app-debug.apk`

- **Release APK** (optimized, shrunk, cleartext HTTP strictly blocked):
  ```bash
  flutter build apk --release --dart-define=API_BASE_URL=https://your-deployed-backend-url.com
  ```
  Output path: `build/app/outputs/flutter-apk/app-release.apk`

---

## Install the APK on an Android Phone

When testing on a personal phone without a developer USB connection:

1. **Transfer the APK to the Phone:**
   - Copy `app-debug.apk` (or `app-release.apk`) to your phone via USB cable, Google Drive, WhatsApp, or email.
2. **Enable "Install Unknown Apps":**
   - Tap on the transferred `.apk` file to open it.
   - If prompted: *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings**.
   - Toggle **Allow from this source** to ON (for Chrome, Files, or WhatsApp), then tap the Back button.
3. **Handle Google Play Protect Warning:**
   - Because the APK is a self-signed development/hackathon build, Google Play Protect may show a dialog: *"Blocked by Play Protect - Unrecognized app details"*.
   - Tap **More details** (small text below the warning).
   - Tap **Install anyway**.
   - Do NOT tap "OK" or "Don't install", as that cancels the installation.
4. **Launch and Test:**
   - Tap **Open** once installation completes.
   - The app will connect directly to your public backend URL over cellular mobile data or Wi-Fi.

