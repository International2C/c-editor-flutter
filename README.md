<img src="assets/meta/icon.png" alt="C-Editor logo" width="150" height="150">

# C-Editor

Level Editor for Plants vs. Zombies 2 Chinese

## Downloads

Release builds are published on [GitHub Releases](https://github.com/International2C/c-editor-flutter/releases). Beta builds are available as workflow artifacts in [GitHub Actions](https://github.com/International2C/c-editor-flutter/actions).

C-Editor can also be accessed from web:

- **Latest stable version available at** [pvz2c-level-editor.vercel.app](https://pvz2c-level-editor.vercel.app/) and mirror at [https://international2c.github.io/c-editor-flutter](https://international2c.github.io/c-editor-flutter) (from `main`)

- **Preview available at:** [c-editor-git-dev-international2c.vercel.app](https://c-editor-git-dev-international2c.vercel.app/) — unstable, built from `dev`.

## Building from source

### Initial setup

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (**≥ 3.44.0**, which ships Dart **≥ 3.12** — the floor in `pubspec.yaml` / `pubspec.lock`). CI and Vercel build against this minimum; newer stables also work. With [FVM](https://fvm.app/): `fvm install` then `fvm use` (reads `.fvmrc`).
2. Enable the platforms you need:
   - **Windows desktop:** `flutter config --enable-windows-desktop` — requires [Visual Studio 2022](https://visualstudio.microsoft.com/) (or Build Tools) with the **Desktop development with C++** workload.
   - **Web:** `flutter config --enable-web`
   - **Android:** Android Studio with the Android SDK and a configured device/emulator.
3. Run `flutter doctor` and fix any blocking issues before building.
4. Clone this repo and install dependencies:

```bash
git clone https://github.com/International2C/c-editor-flutter.git
cd c-editor-flutter
flutter pub get
```

**Linux desktop** additionally needs: `cmake`, `clang`, `ninja-build`, `libgtk-3-dev`, `pkg-config`, `liblzma-dev`, `libstdc++-14-dev`.

On first launch (desktop and mobile), pick a writable **level library** folder. The web build stores levels in browser memory until you download them.

### Run (debug)

```bash
flutter run -d windows   # Windows
flutter run -d linux     # Linux
flutter run -d chrome    # Web
flutter run -d android   # Android
```

### Build (release)

```bash
flutter build windows --release
flutter build linux --release
flutter build apk --release
flutter build web --release
```

Release output locations:

| Platform | Output                                          |
|----------|-------------------------------------------------|
| Windows  | `build/windows/x64/runner/Release/`             |
| Linux    | `build/linux/x64/release/bundle/`               |
| Android  | `build/app/outputs/flutter-apk/app-release.apk` |
| Web      | `build/web/`                                    |

### Other commands

```bash
flutter analyze    # Lint / static analysis
flutter test       # Run tests
flutter gen-l10n   # Regenerate localization (after editing assets/l10n/*.arb)
```

## License

C-Editor is licensed under the [GNU Lesser General Public License v3.0](LICENSE) (see also [COPYING](COPYING) for the GPL-3.0 terms incorporated by LGPL-3.0).

Third-party components kept under their own terms:

| Path | Origin | License |
|------|--------|---------|
| `lib/utils/3rdParty/sen/` | [Sen](https://github.com/harumazzz/Sen) (Haruma) | [GPL-3.0](lib/utils/3rdParty/sen/LICENSE) |
| `lib/utils/3rdParty/pyvz2/` | PyVZ2-derived RTON codec | Covered by this project's LGPL-3.0 (with author permission) |
| `third_party/flutter_eval/` | Vendored [flutter_eval](https://pub.dev/packages/flutter_eval) | BSD-3-Clause |
