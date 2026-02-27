# ⚠️ FULL REBUILD REQUIRED - DO NOT USE HOT RESTART

## The Problem
You're seeing `MissingPluginException` because `mobile_scanner` is a **native plugin** that requires native code compilation. **Hot restart does NOT recompile native code.**

## The Solution: Full Rebuild

### Step 1: STOP the App Completely
- **Press `q` in the terminal** where Flutter is running, OR
- **Stop the app** from your IDE (VS Code/Android Studio)
- **Kill the app** on your device if it's still running

### Step 2: Clean Build (Already Done)
```bash
flutter clean
flutter pub get
```

### Step 3: FULL REBUILD (Not Hot Restart!)
```bash
flutter run
```

Or if using FVM:
```bash
fvm flutter run
```

## ⚠️ IMPORTANT NOTES:

1. **DO NOT** press `R` (hot restart) - this won't work!
2. **DO NOT** press `r` (hot reload) - this won't work!
3. **MUST** do a full rebuild with `flutter run`
4. The first build will take longer (1-2 minutes) as it compiles native code

## After Rebuild:
- The app will request camera permission when you first try to scan
- Grant the permission
- The QR scanner should work properly

## If It Still Doesn't Work:
1. Uninstall the app from your device completely
2. Run `flutter clean` again
3. Run `flutter pub get`
4. Run `flutter run` (full rebuild)

