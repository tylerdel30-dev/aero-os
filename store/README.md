# Aero `.aero` app format (Foundation)

A `.aero` file is a JSON manifest describing an Aero app.

```json
{
  "format": 1,
  "id": "dev.aero.hello",
  "name": "Hello Aero",
  "version": "1.0.0",
  "kind": "foundation-demo",
  "entry": "hello",
  "description": "Example app"
}
```

## Layout

| Path | Role |
|------|------|
| `store/index.json` | Store catalog |
| `store/apps/*.aero` | Published manifests |
| `examples/hello-aero/` | Sample bundle |
| `catalog.json` | Public GitHub catalog |

Foundation 0.2 lists catalog apps in **Start → Aero Store**. Builtins open in-desktop panels; they are not Linux/FreeBSD packages.
