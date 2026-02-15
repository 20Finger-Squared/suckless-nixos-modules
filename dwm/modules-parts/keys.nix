{ lib, config, ... }:
let
  inherit (lib) mkOption types literalExpression;
  commonVariables = (import ../common-variables.nix) { inherit lib config; };
  modifierType = commonVariables.modifierType;
in
{
  options.services.xserver.windowManager.dwm.config.keys = {
    useDefault = mkOption {
      description = "Create default key config, best if you don't want to manually define all keys.";
      type = types.bool;
      default = true;
      example = false;
    };

    bindings = mkOption {
      description = "The definitions for keybindings.";
      type = types.listOf (
        types.submodule {
          options = {
            modifier = mkOption {
              description = "If unbound will use default modifier. Use 0 for no modifier, or modifier strings like MODKEY|ShiftMask.";
              type = modifierType;
              default = "MODKEY";
            };
            key = mkOption {
              description = "Uses X11 keys, remember that SHIFT will modify the keycode.";
              type = types.str;
              default = "XK_p";
            };
            function = mkOption {
              description = "The function to call once the keybind is pressed.";
              type = types.str;
              default = "spawn";
            };
            argument = mkOption {
              description = "The argument for the function.";
              type = types.str;
              default = ".v = dmenucmd";
            };
          };
        }
      );
      default = [ ];
      example = literalExpression ''{ modifier = "MODKEY|ShiftMask"; key = "XK_q"; function = "quit"; argument = "0"; }'';
    };
  };
}
