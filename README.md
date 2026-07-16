# Aero OS Updates

This repository hosts **Aero OS** system updates and app release assets for [`tylerdel30-dev/aero-os`](https://github.com/tylerdel30-dev/aero-os).

## Releases

- Tag releases as `v1.0.1`, `v1.0.2`, and so on.
- Attach `aero-update-manifest.json` plus any updated binaries for that version.
- App packages can be published as `.aero` release assets on the same (or a dedicated) repo.

## On the device

Users apply updates with:

```bash
aero update
# or
aero upgrade
```

The updater reads the latest release, applies the manifest (`replace_only` paths, optional `pkg_upgrade`), and **never touches user files under `/home`**.

## Layout

| Path | Purpose |
|------|---------|
| `catalog.json` | Minimal app catalog pointing at this repo's releases |
| `releases/vX.Y.Z/aero-update-manifest.json` | Per-version update manifests |
| `.github/workflows/release.yml` | Creates a GitHub Release on `v*` tags and uploads the matching manifest |
| `UPDATE.md` | How to publish each new version |

See [UPDATE.md](UPDATE.md) for the publish checklist.
