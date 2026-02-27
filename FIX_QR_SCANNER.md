# Fix QR Scanner Error

## Problem
`MissingPluginException` - This happens because `mobile_scanner` is a native plugin that requires a full rebuild, not just hot reload.

## Solution

### Step 1: Stop the App
Stop the currently running app completely.

### Step 2: Clean and Rebuild
```bash
cd /Users/fardeenkhan/Documents/incuspaze_meeting
flutter clean
flutter pub get
```

### Step 3: Rebuild the App (Full Build)
```bash
flutter run
```

**Important**: Do NOT use hot reload. You must do a full rebuild after adding native plugins.

## Alternative: Use Different QR Scanner Package

If `mobile_scanner` continues to cause issues, we can switch to `qr_code_scanner` which is more stable:

```yaml
qr_code_scanner: ^1.0.1
```

Let me know if you want me to switch to this package instead.

## Current Status

I've added error handling to prevent crashes. The scanner will now:
- Show error message if camera fails to start
- Handle errors gracefully
- Allow stopping the scanner safely

But you still need to do a **full rebuild** (not hot reload) for the native plugin to work.

