{ lib, config }:
let
  inherit (lib) types;
in
{
  cfg = config.services.xserver.windowManager.dwm;
  modifierType = types.nullOr (types.either types.str (types.enum [ 0 ]));
}
