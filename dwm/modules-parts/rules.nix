{ lib, ... }:
let
  inherit (lib) types mkEnableOption mkOption;
in
{
  options.services.xserver.windowManager.dwm.config.rules = mkOption {
    description = "The rules for specific windows to follow.";
    type = types.listOf (
      types.submodule {
        options = {
          isFloating = mkEnableOption "floating mode for this window";

          class = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "WM_CLASS class name to match (e.g., \"Firefox\", \"Gimp\").";
          };

          instance = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "WM_CLASS instance name to match.";
          };

          title = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Window title to match.";
          };

          tag = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = ''Tag where window should appear (1-9), or `null` for the current tag.'';
          };

          monitor = mkOption {
            type = types.int;
            default = -1;
            description = "Monitor index for the window (-1 for current monitor).";
          };
        };
      }
    );
    default = [
      {
        class = "Gimp";
        instance = null;
        title = null;
        tag = null;
        isFloating = true;
        monitor = -1;
      }
      {
        class = "Firefox";
        instance = null;
        title = null;
        tag = 9;
        isFloating = false;
        monitor = -1;
      }
    ];
  };
}
