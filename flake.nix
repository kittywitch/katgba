{
  description = "gba";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    ...
    }:
    let
      inherit (nixpkgs) lib;
      rustTriple = "thumbv4t-none-eabi";
      nixTriple = "arm-none-eabi";
    in flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        pkgsCross = import nixpkgs {
          inherit system;
          config = {
            allowUnsupportedSystem = true;
            #replaceStdenv = ({ pkgs }: pkgs.clangStdenvNoLibs );
          };
          crossSystem = {
            config = nixTriple;
            libc = "newlib";
            #rust.rustcTarget = rustTriple;
            gcc = {
              arch = "armv4t";
            };
          };
        };

        rustToolchainFor =
          p:
          p.rust-bin.selectLatestNightlyWith (
            toolchain:
            toolchain.minimal.override {
              extensions = [ "rust-src" ];
              targets = [ ];
            }
          );
        rustToolchain = rustToolchainFor pkgs;

           craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchainFor;

          myPackage = pkgs.callPackage ./package.nix { inherit craneLib rustToolchain rustTriple; };
      in {
        inherit pkgsCross;
        packages.default = myPackage;
      });
}
