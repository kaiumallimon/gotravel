# GoTravel

Cross‑platform travel booking and management app built with Flutter and Supabase.

## Overview

GoTravel helps users discover travel packages and hotels, manage bookings, view recommendations, and chat with an AI assistant. It uses Supabase for authentication and data, Provider for state management, and a modern, modular Flutter architecture.

## Features

- Supabase email/password authentication
- Browse and search travel packages and hotels
- Add/manage hotels and packages (admin flows)
- Bookings and user profiles stored in Supabase
- Recommendations and conversation flows
- AI assistant (Gemini) for travel guidance
- Location detection and geocoding for nearby suggestions
- Image picking for profile/package images
- In‑app WebView for web content and external URL launching
- Offline‑friendly local caching using Hive

## Tech Stack

- Flutter (Dart ^3.8) with Material 3 theming
- State management: Provider
- Navigation: go_router
- Backend: Supabase (Auth, Database)
- Storage and cache: Hive + hive_flutter
- Networking/Utilities: http, intl, uuid, flutter_dotenv
- UI/UX: flutter_svg, flutter_markdown, quickalert, blur
- Device features: image_picker, geolocator, geocoding, webview_flutter, url_launcher
- AI: flutter_gemini

## Project Structure

Key directories/files:

```
lib/
	main.dart                     # App entry; Supabase init, providers, routing
	core/                         # Core utilities, constants, routing
		routes/
	data/                         # Data layer: services, schemas, repositories
		services/
			remote/                   # Supabase and API integrations
			payment_gateway/
		schemas/                    # SQL or schema helpers
	presentation/                 # UI layer: views, widgets, providers
		providers/
		views/
	theming/                      # Theme, typography, colors

supabase/
	migrations/                   # Database migrations

android/ ios/ macos/ linux/ windows/ web/  # Flutter platform targets
assets/                         # Images, fonts, svgs
	fonts/
	images/
	svgs/
```

## Local Setup

Prerequisites:

- Flutter 3.24+ (Dart 3.8+)
- A Supabase project with URL and Anon key

1) Clone and install dependencies

```powershell
git clone <this-repo-url> ; cd gotravel
flutter pub get
```

2) Environment variables

Create a `.env` file at the project root (loaded by `flutter_dotenv`):

```
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANONKEY=YOUR_SUPABASE_ANON_KEY
```

Make sure `lib/main.dart` calls `dotenv.load()` and initializes Supabase using these values (already wired in this repo).

3) Run the app

```powershell
flutter run
```

## Build & Release

Android:

- Configure a release keystore and signing in `android/app/build.gradle.kts` (currently defaults to debug signing). Follow Flutter’s official signing guide to add a `release` signingConfig and `key.properties`.
- Build a release APK/AAB:

```powershell
flutter build apk --release
# or
flutter build appbundle --release
```

Android manifest notes (important):

- Use modern media permissions. Prefer `READ_MEDIA_IMAGES` (Android 13+) and remove deprecated `WRITE_EXTERNAL_STORAGE`. If you still need gallery access on Android 12 and lower, you can keep `READ_EXTERNAL_STORAGE` with `android:maxSdkVersion="32"`.
- Keep location permissions only if required: `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`. Avoid `ACCESS_BACKGROUND_LOCATION` unless you truly need background tracking.
- Keep `INTERNET` for networking and Supabase. Remove `FOREGROUND_SERVICE` and `WAKE_LOCK` unless you actually run a foreground service.
- If you’ll launch `tel:`, `sms:`, or `mailto:` links via `url_launcher`, add them under `<queries>` for Android 11+ package visibility.
- If you ever load non‑HTTPS content, either enable `android:usesCleartextTraffic="true"` or add a network security config for allowed hosts. Prefer HTTPS whenever possible.

iOS/macOS:

- Set Bundle Identifier and signing in Xcode.
- If you access location/camera/photos, add the corresponding `NS*UsageDescription` keys to `Info.plist`.

Web/Desktop:

- Web uses `web/` assets (manifest, icons). Ensure CORS for your Supabase project if needed.

## Testing

```powershell
flutter test
```

## Key Libraries (pubspec)

- provider: state management
- go_router: declarative routing
- supabase_flutter: auth + database client
- hive, hive_flutter: local storage/cache
- http, intl, uuid: networking, formatting, IDs
- flutter_svg, flutter_markdown, quickalert, blur: UI/UX
- image_picker, geolocator, geocoding: device features
- webview_flutter, url_launcher: web content and external links
- flutter_dotenv: environment variables
- flutter_gemini: AI assistant integration

## Roadmap / Ideas

- Add screenshots/GIF demo in this README (e.g., `assets/images/demo_home.png`)
- E2E tests for critical flows (auth, booking, payments)
- Analytics and performance monitoring

## Contributing

Issues and PRs are welcome. Please format code and follow the existing folder conventions.

## License

Add a license file (e.g., MIT) if you plan to distribute publicly.
