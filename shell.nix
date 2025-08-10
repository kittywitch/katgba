{pkgs, self, rustToolchain}: let
  inherit (pkgs) lib mkShell toilet;
  inherit (lib.meta) getExe;
in mkShell {
    shellHook = ''
      ${getExe toilet} --gay --font mono9 "katgba"
    '';
    nativeBuildInputs = [
      self.packages.${pkgs.system}.katgba-emu
      rustToolchain
    ];
  }
