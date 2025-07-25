{
  mkShell,
  mgba,
  rust-bin
}: mkShell {
  packages = [
    rust-bin.selectLatestNightlyWith (toolchain: toolchain.default)
  ];
};

