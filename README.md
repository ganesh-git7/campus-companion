# Campus Companion

A student attendance and task manager built with Flutter (Material 3). Everything is stored on the device with `shared_preferences`; there is no backend, login, ads or internet permission in the release build.

**Features:** home dashboard · subjects with attended/total classes · overall and per-subject attendance % · warning under 75% with "attend the next N classes" · tasks with due date and priority · pending/completed filter · overdue highlighting · edit/delete with confirmation · data survives app restarts.

## Project layout

```
lib/
  main.dart                      app entry, loads saved data
  models/      subject.dart, task.dart            (plain Dart data classes + JSON)
  services/    attendance_calculator.dart         (all attendance maths)
               storage_service.dart               (shared_preferences)
               app_controller.dart                (app state, ChangeNotifier)
  screens/     main_shell.dart (bottom nav), home_screen.dart,
               attendance_screen.dart, tasks_screen.dart, task_form_screen.dart
  widgets/     reusable cards, dialogs, empty state
  theme/       app_theme.dart (navy / light-blue palette)
  utils/       date_helpers.dart
test/          attendance_calculator_test.dart, models_test.dart
android/       Android platform project (Gradle, manifest, icons)
```

## 1. Windows setup (one time)

1. **Install Git for Windows**: https://git-scm.com/download/win
2. **Install the Flutter SDK** by following https://docs.flutter.dev/get-started/install/windows/mobile
   (choose *Android* as the target). Put it in a path without spaces, e.g. `C:\src\flutter`, and add `C:\src\flutter\bin` to your PATH.
3. **Install Android Studio** (https://developer.android.com/studio). Open it once and let it install the Android SDK, then in *Settings > Languages & Frameworks > Android SDK > SDK Tools* tick **Android SDK Command-line Tools** and **Android SDK Platform-Tools**.
4. Accept the licences and check everything:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor -v
   ```
   Fix anything marked with `[x]` before continuing.
5. **Install VS Code** (https://code.visualstudio.com) and its extensions **Flutter** and **Dart**.

## 2. Extract, open and run (PowerShell)

```powershell
cd $HOME\Downloads
Expand-Archive -Path .\campus_companion.zip -DestinationPath $HOME\Projects -Force
cd $HOME\Projects\campus_companion
code .
```

In the VS Code terminal (`Ctrl+` `` ` ``):

```powershell
flutter pub get
flutter devices
flutter run
```

* **Emulator:** create one in Android Studio (*Device Manager*), or list and launch one from the terminal:
  ```powershell
  flutter emulators
  flutter emulators --launch <emulator_id>
  ```
* **Real phone:** enable *Developer options* and *USB debugging*, connect via USB, accept the prompt on the phone, then check that `flutter devices` lists it.
* If several devices are connected: `flutter run -d <device_id>`.

The first build downloads Gradle and Android build tools, so it can take several minutes and needs internet.

### If the `android` folder gives trouble
The `android/` folder is included and hand-configured (AGP 8.7.3, Gradle 8.10.2, Kotlin 2.1.0, Java 17). If your Flutter version rejects these versions, let Flutter fill in/refresh its own templates without touching your Dart code:
```powershell
flutter create . --platforms=android --org com.campuscompanion --project-name campus_companion
```
Then re-check `android/app/build.gradle` still contains the `key.properties` signing block (see section 5).

## 3. Tests and checks

```powershell
flutter pub get
flutter analyze
flutter test
```

`flutter test` runs the unit tests for attendance calculations: zero classes, below-75% attendance, classes needed to reach 75%, overall percentage, input validation, and model/JSON handling.

## 4. Debugging tips

| Problem | What to try |
|---|---|
| Anything odd | `flutter doctor -v` |
| Stale build errors | `flutter clean` then `flutter pub get` |
| `flutter.sdk not set in local.properties` | run `flutter pub get` (it creates `android/local.properties`) |
| Phone not detected | `adb devices` (from the Android SDK *platform-tools*); re-plug the cable, re-accept the USB prompt |
| Gradle/Java error | Flutter uses Android Studio's bundled JDK; check `flutter doctor -v` shows a Java 17+ path |
| License error | `flutter doctor --android-licenses` |
| See app logs | `flutter logs` or the VS Code *Debug Console* |
| Hot reload / restart | `r` / `R` in the `flutter run` terminal |
| Reset saved data | uninstall the app, or Android *Settings > Apps > Campus Companion > Storage > Clear data* |

## 5. Release APK and signed App Bundle (.aab)

**Quick test APK** (signed with the debug key, only for your own testing):
```powershell
flutter build apk --release
# output: build\app\outputs\flutter-apk\app-release.apk
```

**Signed bundle for Google Play** (your own key; never put it in a ZIP or Git):

1. Create an upload keystore (keep it and its passwords safe, outside the project):
   ```powershell
   keytool -genkey -v -keystore $HOME\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   (`keytool` ships with Android Studio's JDK. If it is not on PATH, use `& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" ...`.)
2. Copy `android\key.properties.example` to `android\key.properties` and fill it in (use forward slashes in `storeFile`, e.g. `C:/Users/you/upload-keystore.jks`).
3. Build:
   ```powershell
   flutter build appbundle --release
   # output: build\app\outputs\bundle\release\app-release.aab
   ```
`android/app/build.gradle` reads `key.properties` automatically. If the file is missing, release builds fall back to the debug key, so **do not upload that build to Google Play**. `key.properties` and `*.jks` are git-ignored and are not included in this project.

## 6. Play Store preparation checklist

1. **Developer account:** register at https://play.google.com/console (one-time fee). Read the current requirements for new accounts, including any mandatory testing period before production release.
2. **Application ID:** change `com.campuscompanion.app` to an ID you own (reverse domain, e.g. `com.yourname.campuscompanion`). It must be changed in `android/app/build.gradle` (`namespace` and `applicationId`), the `package` line and folder path of `MainActivity.kt` (`android/app/src/main/kotlin/...`). It can **never** change after publishing. The simplest safe way: change `applicationId`/`namespace`, rename the Kotlin folders, update the `package` line, then run `flutter clean`.
3. **Version:** edit `version: 1.0.0+1` in `pubspec.yaml`. The number after `+` is the `versionCode` and must increase with every upload.
4. **Target API level:** Google Play requires new apps and updates to target a recent Android API level. This project uses Flutter's current default `targetSdkVersion`; keep Flutter up to date (`flutter upgrade`) and check the current Play policy before each release.
5. **App icon:** the included icon is a simple placeholder. Replace the files in `android/app/src/main/res/mipmap-*` with your own (or use the `flutter_launcher_icons` package).
6. **Store listing:** app name, short and full description, 512x512 icon, 1024x500 feature graphic, at least two phone screenshots.
7. **Policy forms:** *Data safety* (this app collects and shares no user data, and has no internet permission in release builds), *Content rating*, *Target audience*, and a privacy policy URL if the console asks for one.
8. **Play App Signing:** accept it when creating the release. Upload the `.aab` signed with your upload key; Google manages the final app signing key.
9. Test on a real device with the release build before submitting.

## Notes on how attendance is calculated

* Percentage = attended / total * 100. With 0 total classes the percentage is 0 and the app shows "No classes recorded yet".
* Overall = (sum of attended) / (sum of total) * 100, not the average of the subject percentages.
* Classes needed to reach 75%: the smallest whole `x` with `(attended + x) / (total + x) >= 0.75`, i.e. `x = max(0, 3 * total - 4 * attended)`. It is always reachable for 75% (attending every future class approaches 100%).
