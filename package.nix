{ lib, craneLib, rustToolchain, rustTriple, gcc-arm-embedded }: let
  linkerFilter = path: _type: builtins.match ".ld$" path != null;
  txtFilter = path: _type: builtins.match ".txt$" path != null;
  linkerOrCargo = path: type:
    (linkerFilter path type) || (txtFilter path type ) || (craneLib.filterCargoSources path type);
  commonArgs = let
        unfilteredRoot = ./.;
        src = lib.fileset.toSource {
          root = unfilteredRoot;
          fileset = lib.fileset.unions [
            # Default files from crane (Rust and cargo files)
            (craneLib.fileset.commonCargoSources unfilteredRoot)
            # Also keep any linker files
            (lib.fileset.fileFilter (file: file.hasExt "ld") unfilteredRoot)
            # Also keep any txt files
            (lib.fileset.fileFilter (file: file.hasExt "txt") unfilteredRoot)
            # Example of a folder for images, icons, etc
            (lib.fileset.maybeMissing ./src/foo.txt)
            (lib.fileset.maybeMissing ./build.rs)
          ];
    };
    in {
          inherit src;
          strictDeps = true;
          cargoVendorDir = craneLib.vendorMultipleCargoDeps rec {
            inherit (craneLib.findCargoFiles src) cargoConfigs;
            cargoLockList = [
              "${unfilteredRoot}/Cargo.lock"
              # Unfortunately this approach requires IFD (import-from-derivation)
              # otherwise Nix will refuse to read the Cargo.lock from our toolchain
              # (unless we build with `--impure`).
              #
              # Another way around this is to manually copy the rustlib `Cargo.lock`
              # to the repo and import it with `./path/to/rustlib/Cargo.lock` which
              # will avoid IFD entirely but will require manually keeping the file
              # up to date!
              "${rustToolchain.passthru.availableComponents.rust-src}/lib/rustlib/src/rust/library/Cargo.lock"
            ];
          };

        cargoExtraArgs = "-Z build-std --target ${rustTriple}";
      nativeBuildInputs = [
        # Add additional build inputs here
        gcc-arm-embedded
      ];
        doCheck = false;
  };
    artifacts = craneLib.buildDepsOnly(commonArgs // {
      pname = "katgba-deps";
    });
    package = craneLib.buildPackage (commonArgs // rec{
    cargoArtifacts = artifacts;

          doCheck = false;
          });
  in package
