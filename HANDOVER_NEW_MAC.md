# New Mac Handover Guide (Critical for Play Upload)

This guide prevents Play Console upload failures caused by signing mismatch, package mismatch, or version code issues.

## 1) Never Change These

1. Package ID must stay exactly: `com.filmmend.me`
2. Play app listing must remain the same app in your Play Console
3. Upload keystore identity must stay the same (same keystore + alias)

Project locations that must remain aligned:

- [android/app/build.gradle.kts](android/app/build.gradle.kts)
  - `namespace = "com.filmmend.me"`
  - `applicationId = "com.filmmend.me"`
- [android/app/google-services.json](android/app/google-services.json)
  - must include Android client for `com.filmmend.me`

## 2) Files You Must Copy From Old Mac

Copy these files exactly to the same relative paths in the repo:

1. [android/upload-keystore.jks](android/upload-keystore.jks)
2. [android/key.properties](android/key.properties)
3. [android/app/google-services.json](android/app/google-services.json)

If any one of these is missing or wrong, upload can fail.

## 3) Verify Signing On New Mac

Check [android/key.properties](android/key.properties) values:

1. `storeFile=upload-keystore.jks`
2. `keyAlias=upload`
3. passwords must match the original upload keystore

Build file already reads this in [android/app/build.gradle.kts](android/app/build.gradle.kts) under `signingConfigs.release`.

## 4) Version Code Rule (Most Common Upload Blocker)

Play requires a strictly increasing version code.

In this project, version code comes from [pubspec.yaml](pubspec.yaml):

- `version: 1.0.0+8`
- the number after `+` is the Android version code

Before each upload:

1. Check highest version code already uploaded in Play Console
2. Set [pubspec.yaml](pubspec.yaml) `+N` to a higher number
3. Run `flutter pub get`
4. Build new AAB

If Play says version already used, increase `+N` and rebuild.

## 5) New Mac Setup Checklist

1. Install Flutter stable and Android Studio
2. Run:
   - `flutter doctor -v`
   - `flutter doctor --android-licenses`
3. Open project and run:
   - `flutter pub get`
   - `flutter analyze`
4. Build release AAB:
   - `flutter build appbundle --release`
5. Confirm artifact exists:
   - [build/app/outputs/bundle/release/app-release.aab](build/app/outputs/bundle/release/app-release.aab)

## 6) Pre-Upload Safety Checks

1. Git clean state:
   - `git status -sb`
2. Package ID still correct in [android/app/build.gradle.kts](android/app/build.gradle.kts)
3. Version code bumped in [pubspec.yaml](pubspec.yaml)
4. Release build succeeds
5. Upload to Internal testing first, then verify install

## 7) Common Errors and Exact Fix

### Error: "Your Android App Bundle is signed with the wrong key"

Cause:

- wrong keystore or wrong alias/password

Fix:

1. Restore original [android/upload-keystore.jks](android/upload-keystore.jks)
2. Restore matching [android/key.properties](android/key.properties)
3. Rebuild and re-upload

### Error: "Version code X has already been used"

Cause:

- version code not incremented

Fix:

1. Increase `+N` in [pubspec.yaml](pubspec.yaml)
2. `flutter pub get`
3. rebuild AAB and upload

### Error: "No matching client found for package name"

Cause:

- Firebase Android config does not match package ID

Fix:

1. Regenerate Android app config in Firebase for `com.filmmend.me`
2. Replace [android/app/google-services.json](android/app/google-services.json)
3. Rebuild

## 8) Recommended Release Workflow

1. Bump [pubspec.yaml](pubspec.yaml) version code
2. `flutter pub get`
3. `flutter analyze`
4. `flutter build appbundle --release`
5. Upload to Internal testing
6. Verify install and launch
7. Promote once stable

## 9) Emergency Recovery (If Old Mac Is Lost)

If upload keystore is lost, you cannot keep signing with it locally.
You must request upload key reset in Play Console (App integrity).
This can delay releases, so keep secure backups of:

1. [android/upload-keystore.jks](android/upload-keystore.jks)
2. [android/key.properties](android/key.properties)

## 10) Keep This Updated

Whenever release process changes, update this file first.

Current known good baseline:

1. package: `com.filmmend.me`
2. version code: `8`
3. release artifact path: [build/app/outputs/bundle/release/app-release.aab](build/app/outputs/bundle/release/app-release.aab)
