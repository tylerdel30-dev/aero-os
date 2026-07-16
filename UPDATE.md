# Publishing an Aero OS update

1. **Bump the version** (e.g. `1.0.0` → `1.0.1`).
2. **Add a manifest** at `releases/vX.Y.Z/aero-update-manifest.json` (set `from_version`, `to_version`, notes, and file lists).
3. **Commit and push** to `main`.
4. **Tag and push** the release:

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

5. The **release workflow** creates a GitHub Release for that tag and uploads `aero-update-manifest.json` from `releases/vX.Y.Z/` (or a root template if present).
6. **Attach binaries** (and optional `.aero` app packages) to the release if needed:

   ```bash
   gh release upload vX.Y.Z path/to/binary ...
   ```

Devices pick up the new release via `aero update` / `aero upgrade`.
