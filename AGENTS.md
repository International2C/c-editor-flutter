# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

**c_editor** is a cross-platform **Flutter** desktop/mobile/web app — a Level Editor for Plants vs. Zombies 2 Chinese. Package name: `C-Editor`. It is a purely client-side application with no backend services, databases, or Docker containers.

Source: https://github.com/International2C/c-editor-flutter

### SDK requirements

- **Flutter SDK ≥ 3.44.0** (first stable shipping **Dart 3.12**, the floor set by `pubspec.yaml` / `pubspec.lock`). CI, Vercel, and `.fvmrc` pin **3.44.0** as the minimum; newer stables work too.
- `pubspec.yaml` enforces `sdk: ^3.12.0` and `flutter: ">=3.44.0"`. When raising the floor, update `.fvmrc`, `vercel-build.sh`, `tool/build_web.*`, and the GitHub workflows (including `.github/workflows/deploy-pages.yml`) together.
- **FVM users:** `fvm use` / `fvm install` will pick up `.fvmrc`.
- **Cursor Cloud (Linux):** Flutter is installed at `/home/ubuntu/flutter` and added to PATH via `~/.bashrc`.
- **Windows (local):** Install the [Flutter SDK for Windows](https://docs.flutter.dev/get-started/install/windows), enable **Windows desktop** (`flutter config --enable-windows-desktop`), and install **Visual Studio 2022** (or Build Tools) with the **Desktop development with C++** workload. Run `flutter doctor` until the Windows toolchain shows no blocking issues.

### Linux desktop build dependencies

The following system packages are required for `flutter build linux` / `flutter run -d linux`:

- `cmake`, `clang`, `ninja-build`, `lld`, `llvm-18`, `libgtk-3-dev`, `pkg-config`, `liblzma-dev`, `libstdc++-14-dev`

A `libstdc++.so` symlink must exist at `/usr/lib/x86_64-linux-gnu/libstdc++.so` (pointing to `libstdc++.so.6`). If missing, create it: `sudo ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so`.

### Windows desktop notes

- No extra packages beyond what `flutter doctor` lists for the VS C++ toolchain.
- Use **PowerShell** or **cmd**; chain commands with `;` (PowerShell does not support `&&` in older versions).
- Release output: `build\windows\x64\runner\Release\` (executable and DLLs in that folder).
- First launch still requires choosing a writable **level library** folder (any local path the user can read/write).

### Common commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Regenerate l10n | `flutter gen-l10n` |
| Lint / analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Build Linux | `flutter build linux` |
| Run (debug, Linux) | `flutter run -d linux` |
| Build Windows | `flutter build windows` |
| Run (debug, Windows) | `flutter run -d windows` |
| Run (debug, Chrome) | `flutter run -d chrome` |
| Compile web export worker | `dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2` |
| Build web (app + worker) | `./tool/build_web.ps1` (Windows) or `./tool/build_web.sh` (Linux/macOS) |
| Compile sample plugin | `flutter test test/tools/compile_hello_cplugin_test.dart` |
| Debug a plugin in C-Editor | `flutter run -d windows --dart-define=CPLUGIN_DEBUG_PATH=plugin_example/hello_cplugin` (or Plugins → **Load folder (debug)**) |

### Plugin authoring

- Sample: `plugin_example/hello_cplugin/` (package layout: `manifest.json`, `lib/main.dart`, `assets/`).
- Debug **inside the real C-Editor app** (not a separate host): set `CPLUGIN_DEBUG_PATH` to the plugin package root, or use **Plugins → Load folder (debug)**. That compiles sources to EVC and installs them; re-run / reload after edits (plugin code is not Dart hot-reload).
- Ship: compile + pack to `.cplugin`, then install from device/URL.

### Gotchas

- The app requires a writable folder configured as its "level library" on first launch. Create or pick a directory from the initial setup screen (Linux, Windows, and other platforms).
- `flutter analyze` may report pre-existing info/warning-level lint issues. Treat new errors as regressions.
- EGL/DRI3 warnings at app launch (`libEGL warning: DRI3 error`) are expected in headless/container Linux environments and do not affect functionality.
- Localization files under `lib/l10n/` are auto-generated (`generate: true` in `pubspec.yaml`). Do not edit them directly; edit `assets/l10n/*.arb` instead, then run `flutter gen-l10n`.
- Edit ARB files for user-facing copy (about screen, credits, etc.); keep `lib/screens/about_screen.dart` in sync when adding new localized keys or link behavior.
- External URLs (GitHub, Discord, Recommended levels, etc.) live in `assets/meta/links.json` and are loaded via `lib/data/app_links.dart` — change links there rather than hardcoding in Dart.
- **Web RSB export runs in a Web Worker.** `web/rsb_worker.dart` is a *separate* Dart entrypoint compiled to `web/rsb_worker.dart.js` (committed), which runs the CPU-heavy sen pack/unpack pipeline off the UI thread. Flutter does not compile it during `flutter build web`, so **recompile it whenever `web/rsb_worker.dart`, `lib/screens/export/rsb_pipeline.dart`, or any `lib/utils/3rdParty/sen/**` file changes** — use `tool/build_web.ps1`/`tool/build_web.sh`, or run the `dart compile js` command above. The shared pipeline lives in `lib/screens/export/rsb_pipeline.dart` and the main/worker message contract in `lib/screens/export/rsb_worker_protocol.dart`. If the compiled worker is missing, `ExportEngineWeb` transparently falls back to the main isolate (works, but freezes the tab during pack).
- **Two web deploy targets, both from `main`.** Vercel (`vercel.json` + `vercel-build.sh`, served at root `/`) and GitHub Pages (`.github/workflows/deploy-pages.yml`, served at `/<repo>/`). Both build the JS (dart2js) target — no `--wasm` — and pass `PVZ2C_ENCRYPTION_KEY` via `.github/scripts/flutter-dart-defines.sh` (required so encrypted resources decrypt and zombie/plant names localize instead of showing raw codenames). The Pages job sets `--base-href` from the repo name (override with the `PAGES_BASE_HREF` repo variable, e.g. `/` for a user page or custom domain) and writes `404.html` for deep-link fallback. Pages cannot set COOP/COEP headers, which is why the wasm-threaded target is intentionally avoided. **Prerequisites (one-time in repo settings):** set Pages source to "GitHub Actions", and add the `PVZ2C_ENCRYPTION_KEY` secret.
