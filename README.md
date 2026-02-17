# Kurukshetra Local Dealz Demo

Flutter demo app for local brands and coupons.

## Run Without OneDrive Lock Errors

If Chrome/Flutter fails with:

`Flutter failed to delete a directory at "build\\flutter_assets"...`

use the safe launcher script:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_chrome_safe.ps1
```

This script:

1. Stops lock-prone processes (`dart`, `flutter`, `chrome`, `msedge`, `OneDrive`)
2. Removes temporary lock-prone folders (`build`, `.dart_tool`, `windows/flutter/ephemeral`)
3. Runs `flutter pub get`
4. Starts `flutter run -d chrome`

### Optional

Only clean/unlock without launching:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_chrome_safe.ps1 -NoRun
```

## Permanent Best Fix

For a permanent fix, keep the project outside OneDrive sync folders (for example `C:\dev\cupon`), because OneDrive file virtualization frequently locks Flutter build outputs.
