# zmk-config-totem (no-studio branch)

Custom ZMK firmware for the [TOTEM][totem] 38-key split keyboard.

Keymap structure is borrowed from [bsag/zmk-config-bsag][bsag] (modular,
nodefree-style includes, home-row mods, mod-morphs, lots of combos) but
the base layer is **QWERTY** instead of Colemak-DH. The shield definition
is based on [cvaldezcomputerer/zmk-config][cvaldez] / [GEIGEIGEIST/TOTEM][totem].

**This branch drops ZMK Studio** (the Studio build caused an off-by-one
shift on the bottom row that the plain firmware doesn't have). The
keypeek raw-HID overlay support is still present as an optional build.

[totem]: https://github.com/GEIGEIGEIST/TOTEM
[bsag]: https://github.com/bsag/zmk-config-bsag
[cvaldez]: https://github.com/cvaldezcomputerer/zmk-config
[studio]: https://zmk.dev/docs/features/studio
[keypeek]: https://github.com/srwi/keypeek

## Repository layout

```
.
├── build.yaml                     # GitHub Actions build matrix (3 targets)
├── config/
│   ├── west.yml                   # Module manifest (zmk + 3 modules)
│   ├── totem.conf                 # User-level ZMK config
│   ├── totem.keymap               # The keymap (QWERTY, HRM, 5 layers)
│   └── combos.dtsi                # Combos definition
├── boards/shields/totem/          # 38-key TOTEM shield definition
│   ├── totem.dtsi                 # Matrix + kscan + physical-layout chosen
│   ├── totem-layouts.dtsi         # Physical layout for Studio
│   ├── totem_left.overlay         # Left half (central) col-gpios
│   ├── totem_right.overlay        # Right half (peripheral) col-gpios
│   ├── totem.zmk.yml              # Shield metadata (declares Studio support)
│   ├── Kconfig.shield
│   └── Kconfig.defconfig
├── zephyr/module.yml              # Exposes boards/ as a Zephyr module
└── .github/workflows/build.yml    # Uses zmkfirmware/zmk reusable workflow
```

## Pushing to your own GitHub repo

```bash
cd "C:\Users\AlexLai\Documents\Totem"
git init -b main
git add .
git commit -m "Initial Totem ZMK config"

# Create an empty repo on github.com first, then:
git remote add origin git@github.com:<your-username>/zmk-config-totem.git
git push -u origin main
```

Once the push lands, GitHub Actions runs automatically. The first build
takes 5–10 minutes (it pulls Zephyr SDK + ZMK + all modules). On
subsequent runs it's mostly cached.

## Build artifacts

Every push produces a `firmware.zip` artifact with these `.uf2` files:

| File | Where to flash |
|---|---|
| `totem_left-xiao_ble-zmk.uf2` | Left half (central — talks to host) |
| `totem_right-xiao_ble-zmk.uf2` | Right half (peripheral) |
| `totem_left_keypeek-xiao_ble-zmk.uf2` | Replaces left when you want the keypeek overlay |
| `settings_reset-xiao_ble-zmk.uf2` | Flash to wipe stored settings (BT pairings, etc) |

### Flashing

1. Plug the half into USB.
2. Double-tap the reset button — it mounts as a USB drive (`XIAO-SENSE` or `NICENANO`).
3. Drag the `.uf2` onto the drive. It reboots automatically.

After flashing both halves the first time, hold the rightmost outer key
on each side at power-on (or run the BT clear combo) to clear stale
pairing info if the halves don't find each other.

## keypeek (on-screen layer overlay)

[keypeek][keypeek] is a host-side Rust app that draws your current
layer over your other windows. It reads layer + key events from the
keyboard over USB Raw HID.

1. Flash `totem_left_keypeek-...-zmk.uf2` to the left half. (This
   replaces the regular `totem_left` firmware. The right half can
   stay on `totem_right`.)
2. Download keypeek from <https://github.com/srwi/keypeek/releases>.
3. Plug the left half into USB, launch keypeek, pick the TOTEM from
   the device list.
4. The overlay redraws when you press a layer key.

Works on Windows, macOS, and Linux.

## Keymap quick reference

- **5 layers**: BASE (QWERTY), NAV (arrows), NUM (numpad), FUN (F-keys),
  UTIL (BT + media).
- **Home-row mods**: `Ctrl Alt GUI Shift` on `A S D F` / `J K L ;` —
  hold any of those to apply the mod.
- **Thumb layer-taps**: left thumb gives `Esc / Space / Shift` (taps)
  with `UTIL / NAV` (holds); right thumb gives `Return / Backspace /
  Delete` (taps) with `NUM / FUN` (holds).
- **Symbol combos**: chord any two adjacent keys vertically to get
  shift-symbols (`@ # $ %` on top+home L, `^ + * &` on top+home R, etc.).
  See `config/combos.dtsi` for the full table.
- **Brackets**: chord adjacent top-row R for `[ ]`, middle-row R for
  `( )`, bottom-row R for `{ }`.
- **Caps Word**: chord both index fingers (`F + J`).

The full layout lives in `config/totem.keymap` — go there to remap.

## Updating modules

To pull the latest zmk-helpers / zmk-raw-hid / keypeek-notifier:

```bash
# In the repo root (after cloning to your local machine), no action
# is needed locally — the build runs west update on every CI run.
# To pin a specific commit, edit config/west.yml and replace
# revision: main  with  revision: <sha>
```

## Credits

- bsag — keymap structure, combos, HRM tuning
- urob — `zmk-helpers` macros, the HRM patterns this builds on
- cvaldez — TOTEM shield + Studio integration patterns
- GEIGEIGEIST — TOTEM hardware design
- zzeneg — `zmk-raw-hid` module
- srwi — keypeek + layer-notifier module
