# katgba

Currently an example Rust game from the GBA crate, but with nix building.

## Usage

```
# Build rom
nix build .#katgba

# Use mgba-qt with a built rom
nix run .#katgba-emu
```
