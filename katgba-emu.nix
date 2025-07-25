{ writeShellScriptBin, mgba, lib, katgba }:

let
  inherit (lib.meta) getExe';
in writeShellScriptBin "katgba-emu" ''
  ${mgba}/bin/mgba-qt ${getExe' katgba "katgba"}
''
