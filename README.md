# katgba

Currently an example Rust game from the GBA crate, but with nix building.

Hopefully eventually a series of game projects to learn how to make games on smol hardware

Emphasis on learning:

* embedded programming
* game development
* building abstractions

## Usage

```
# Build rom
nix build .#katgba

# Use mgba-qt with a built rom
nix run .#katgba-emu
```
