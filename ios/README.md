# iOS platform folder — regenerating the Xcode project file

Everything you would actually customize for HIMICO AI's iOS build is
already here and hand-authored to match the app's branding and
requirements:

- `Runner/Info.plist` — app name, orientation, permissions
  (photo library access for journal screenshots), dark status bar.
- `Runner/AppDelegate.swift` — Flutter plugin registration entry point.
- `Runner/Base.lproj/LaunchScreen.storyboard` — dark cyberpunk splash
  screen matching the in-app theme.
- `Runner/Base.lproj/Main.storyboard` — root FlutterViewController.
- `Runner/Assets.xcassets/AppIcon.appiconset` — full icon set (20pt–1024pt)
  generated from the HIMICO AI mark.
- `Podfile` — CocoaPods integration for Flutter plugins.
- `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig` — build config
  includes.

The one file intentionally **not** hand-written here is
`Runner.xcodeproj/project.pbxproj`. It's a large, machine-generated file
of UUID cross-references between build targets, file references, and
build phases — Xcode and Flutter tooling regenerate it deterministically
from the files above, and hand-authoring it risks subtle corruption that
silently fails to open in Xcode.

To generate it (one-time, safe, does not touch `lib/` or any other
platform folder):

```bash
flutter create --platforms=ios .
```

Run this from the project root after copying in this `ios/` folder as-is.
Flutter will detect the existing customized files (Info.plist, storyboards,
icons, Podfile) and only fill in the missing `project.pbxproj` /
`.xcworkspace` scheme wiring, then:

```bash
cd ios && pod install && cd ..
flutter build ios
```

The Android build (the primary target for this project) does **not**
require this step — `android/` is a complete, ready-to-build Gradle
project as-is.
