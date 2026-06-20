# Serial Integration Factory

This repository is a workspace for building **two deliverables** for a given
RS232-controlled device:

1. **A serial library** — an async Python package that talks to the device over
   RS232 (a standalone GitHub repo, named `<device>-rs232`).
2. **A Home Assistant custom integration** — a HACS-installable integration that
   *vendors* (bundles) the library to integrate the device into Home Assistant.

## Reference material

**Before doing anything else, run `./setup.sh`.** It (shallow) clones the
reference repositories into `reference/`, and if they already exist it pulls the
latest changes. They are gitignored — read-only examples, never edit them.

| Path | Use as a template for |
| --- | --- |
| `reference/denon-rs232` | Serial library, **receiver / AV device** flavor |
| `reference/lg-rs232-tv` | Serial library, **TV device** flavor |
| `reference/integration_blueprint` | The HACS custom-integration structure |
| `reference/home-assistant-core` | How HA's built-in integrations model entities (look up the closest existing integration for the device class) |

## Workflow

Follow these steps in order. Do not skip ahead.

### 0. Fetch references

Run `./setup.sh` to clone/update the `reference/` repositories.

### 1. Get the protocol documentation

**Ask the user where the RS232 documentation lives** (a path, a URL, a PDF).
Do not proceed without it — the protocol doc is the source of truth for every
command, query, and response in the library.

Each device gets its own **parent folder** at the repo root, named after the
device (lowercase), holding both deliverables. For example, for Marantz:

```
marantz/
  marantz-rs232/          -- the library (deliverable 1)
    docs/                 -- the original RS232 documentation lives here
  marantz-rs232-hass/     -- the HACS integration (deliverable 2)
```

Move the original RS232 documentation into the library's `docs/` folder
(`<device>/<device>-rs232/docs/`) so it ships with the library as the source of
truth. If the doc is a URL, download it into `docs/`.

### 2. Establish the device type

Read the docs and determine what kind of device it is. This picks the example
library you mirror:

- **Receiver / amplifier / AV device → use `denon-rs232` as the example.**
- **Anything else (TV, display, projector, …) → use `lg-rs232-tv` as the example.**

### 3. Build the serial library

Create a new repo/folder named `<device>-rs232` (always include `rs232` in the
name). **Mirror the exact folder structure of the chosen example library**,
including the `.github/workflows/` test + publish CI.

The example library structure (from `denon-rs232` / `lg-rs232-tv`):

```
<device>/<device>-rs232/
  docs/             -- the original RS232 protocol documentation
  src/<device>_rs232/
    __init__.py     -- public API: enums, <Device>State, <Device> class
    const.py        -- protocol constants (prefixes, baud, timeouts)
    protocol.py     -- framing / encode / decode of the RS232 wire format
    state.py        -- the device state dataclass
    <device>.py     -- the main device class (e.g. receiver.py / tv.py)
    __main__.py     -- CLI for testing a live serial connection
    py.typed
    models.py       -- (optional) per-model definitions, like denon-rs232
  tests/
    conftest.py     -- MockSerialConnection + fixtures (no real hardware)
    test_*.py       -- protocol, query, control, event tests
  .github/workflows/test.yml
  .github/workflows/publish.yml
  pyproject.toml
  .python-version
  README.md
  LICENSE
  .gitignore
  AGENTS.md         -- describe the library (see the examples)
  CLAUDE.md         -- symlink to AGENTS.md
```

Architecture conventions to copy from the examples:
- Async serial I/O via `serialx` (`open_serial_connection`), typically 9600 8N1.
- `connect()` opens/verifies the connection; `query_state()` populates state;
  a background read loop keeps state current and notifies subscribers.
- Tests use a `MockSerialConnection` — **never require real hardware to test.**
- Map the documented commands into typed enums; keep free-form values as `str`.

### 4. Build the Home Assistant custom integration

Look up the closest existing integration in `reference/home-assistant-core`
(e.g. a `media_player` integration for a receiver or TV) to model entity
behavior and feature flags — but **ship it as a HACS custom integration**, not a
core PR.

**Mirror the structure of `reference/integration_blueprint`** and **vendor the
library** (copy the library's `src/<device>_rs232/` package into the integration
so HACS can install it without a PyPI dependency). This is deliverable 2, at
`<device>/<device>-rs232-hass/`:

```
<device>/<device>-rs232-hass/
custom_components/<domain>/
  <device>_rs232/        -- vendored copy of the library package
  __init__.py
  config_flow.py         -- ask for the serial port
  const.py
  coordinator.py         -- DataUpdateCoordinator wrapping the library
  data.py
  entity.py
  manifest.json          -- domain, name, config_flow, version, iot_class
                            (local_push if the device emits unsolicited state
                             changes over serial; otherwise local_polling)
  <platform>.py          -- media_player (or appropriate platform)
  translations/en.json
hacs.json
requirements.txt
.github/workflows/{lint,validate}.yml
README.md
LICENSE
```

### 5. Deliverables

Both live under the device's parent folder and are ready to push to GitHub:
1. `<device>/<device>-rs232` — the library (publishable to PyPI, CI runs tests,
   protocol docs in `docs/`).
2. `<device>/<device>-rs232-hass` — the HACS-installable custom integration with
   the library vendored in.

## Notes

- One device per run. Ask for the protocol docs first; everything follows from them.
- Each device gets its own `<device>/` parent folder holding both deliverables.
- Keep changes inside the device's parent folder. Never edit `reference/`.
