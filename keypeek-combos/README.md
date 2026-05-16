# keypeek + combo display

This folder holds everything you need to build your own version of
[keypeek][keypeek] that renders combos as colored arcs over the keymap
overlay — like keymap-drawer's static SVG, but live on top of your screen.

[keypeek]: https://github.com/srwi/keypeek

## What's in here

| File | Purpose |
|---|---|
| `combo-display.patch` | Diff against upstream `srwi/keypeek` adding combo support |
| `combos.yaml` | Combo definitions for **your** Totem keymap |
| `README.md` | This file |

## How combo display works

Stock keypeek doesn't know about combos because ZMK Studio's RPC protocol
doesn't expose them. This patch sidesteps that: it reads a YAML file
(`combos.yaml`) at startup and overlays the combos on top of the existing
keypeek overlay. Each combo is drawn as red lines connecting its chord
positions, with the output keycode labeled at the center.

This means combos are **defined client-side**, not read from the keyboard.
If you change a combo in `combos.dtsi`, you also have to update `combos.yaml`
to keep the visualization in sync. (The advantage: no firmware-side work.)

## Build it (Windows)

1. **Install Rust** — <https://rustup.rs/> — run the installer, accept defaults.
   This installs `cargo`, the Rust build tool.

2. **Clone your fork of keypeek**

   ```powershell
   # On github.com, click "Fork" on srwi/keypeek to create your own copy.
   cd C:\src   # or wherever you keep source
   git clone https://github.com/<your-username>/keypeek.git
   cd keypeek
   ```

3. **Apply the patch**

   ```powershell
   git checkout -b combo-display
   git apply C:\Users\AlexLai\Documents\Totem\keypeek-combos\combo-display.patch
   git add -A
   git commit -m "Add combo overlay from combos.yaml"
   ```

4. **Build**

   ```powershell
   cargo build --release
   ```

   First build will take ~5 minutes (pulls + compiles all dependencies).
   The output binary is at `target\release\keypeek.exe`.

5. **Run with combos**

   ```powershell
   # Copy the combos.yaml from this folder to next to the .exe
   copy C:\Users\AlexLai\Documents\Totem\keypeek-combos\combos.yaml target\release\
   target\release\keypeek.exe
   ```

   At startup, you should see something like `keypeek: loaded 29 combos from
   .../combos.yaml` in stderr (visible if you launch from a terminal).

## Build it (macOS)

Same flow, with the obvious changes:

```bash
brew install rust   # or via rustup.rs
git clone https://github.com/<you>/keypeek.git
cd keypeek
git checkout -b combo-display
git apply ~/path/to/combo-display.patch
cargo build --release
cp ~/path/to/combos.yaml target/release/
./target/release/keypeek
```

## What you'll see

On the overlay, every combo defined in `combos.yaml` shows up as red lines
radiating from a central label. Two-key combos look like a single line with
the label at the midpoint. Three-key combos (like `J+K+L` for Enter) look
like a Y-shape with the label at the centroid.

The combos respect keypeek's existing visibility rules — they show when the
overlay is active (base layer when "always display" is on; non-base layers
otherwise).

## Keeping it in sync with your firmware

When you change combos in `config/combos.dtsi`, also update `combos.yaml`
here. The position numbers must match — they're indices into the matrix
transform's position list (row-major: 0–9 top, 10–19 home, 20–29 bottom,
30 = outer pinky L, 31–33 left thumbs, 34–36 right thumbs, 37 = outer pinky R).

## Filing a PR upstream

If you find this useful, consider sending the patch upstream to
`srwi/keypeek` — it'd benefit anyone using ZMK combos. You'd want to:

- Move the `combos.yaml` path to a configurable setting (instead of fixed
  filename next to the exe), so users can pick where to put their config.
- Add a UI affordance in the settings window for choosing the file.
- Maybe support pulling combo definitions from the firmware module if the
  layer-notifier ever exposes them via a side-channel packet (the cleaner
  long-term fix).
