# How to publish every Aero OS update (1.0.1, 1.0.2, …)

This repo (`tylerdel30-dev/aero-os`) is the update channel for Aero OS.

## For every new version

1. Bump the version in the OS tree (`/etc/aero-version` / build script) to the new number, e.g. `1.0.2`.
2. Copy the last manifest:
   ```
   releases/v1.0.1/aero-update-manifest.json  →  releases/v1.0.2/aero-update-manifest.json
   ```
3. Edit the new manifest:
   - `from_version` = previous (e.g. `1.0.1`)
   - `to_version` = new (e.g. `1.0.2`)
   - Update `notes`
4. Commit and push to `main`.
5. Create a GitHub Release tagged **exactly** `v1.0.2` (always start with `v`).
6. Attach as Release assets:
   - `aero-update-manifest.json` (required — Aero downloads this first)
   - Updated binaries you want replaced (`aero-shell`, `aero`, `style.css`, …)
   - Optional: `.aero` app packages for the store

## What users do

```
aero update    # checks GitHub for a newer tag than /etc/aero-version
aero upgrade   # downloads manifest + files, shows update screen, never touches /home
```

Or: **Settings → Software Update → Check for Updates / Install**.

## Safety

Updates only replace paths listed under `replace_only`.
Paths under `preserve_paths` (especially `/home`) are never overwritten.
