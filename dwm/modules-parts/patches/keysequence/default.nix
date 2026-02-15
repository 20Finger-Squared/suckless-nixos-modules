{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;

  key-bind-type = types.submodule {
    options = {
      modifier = mkOption {
        type = types.either types.str (types.enum [ 0 ]);
        default = "MODKEY";
        description = "If left unbound will use default modifier. Use 0 for no modifier, or modifier strings like MODKEY|ShiftMask.";
      };
      key = mkOption {
        type = types.str;
        default = "XK_p";
        description = "Uses X11 keys, remember that SHIFT will modify the keycode.";
      };
      function = mkOption {
        type = types.str;
        default = "spawn";
        description = "The function to call once the keybind is pressed.";
      };
      argument = mkOption {
        type = types.str;
        default = ".v = dmenucmd";
        description = "The argument for the function.";
      };
    };
  };
  commonVariables = (import ../../../common-variables.nix) { inherit lib config; };
  modifierType = commonVariables.modifierType;
in
{
  options.services.xserver.windowManager.dwm.config.patches.keysequence = {
    enable = mkEnableOption "the keysequence patch for dwm";
    keys = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            activationKey = {
              modifier = mkOption {
                type = modifierType;
                default = "MODKEY";
                description = "If left unbound will use default modifier. Use 0 for no modifier, or modifier strings like MODKEY|ShiftMask.";
              };
              key = mkOption {
                type = types.str;
                description = "Uses X11 keys, remember that SHIFT will modify the keycode.";
              };
            };

            bindings = mkOption {
              type = types.listOf (key-bind-type);
              description = "The definitions for keysequences.";
              example = {
                modifier = 0;
                key = "XK_q";
                function = "quit";
                argument = "0";
              };
            };
          };
        }
      );
      default = [
        {
          activationKey = {
            modifier = "MODKEY";
            key = "XK_a";
          };
          bindings = [
            {
              modifier = 0;
              key = "XK_t";
              function = "setlayout";
              argument = "{ .v = &layouts[0] }";
            }
            {
              modifier = "ShiftMask";
              key = "XK_t";
              function = "setlayout";
              argument = "{ .v = &layouts[1] }";
            }
            {
              modifier = "MODKEY";
              key = "XK_y";
              function = "setlayout";
              argument = "{ .v = &layouts[2] }";
            }
          ];
        }
      ];
    };
  };
}
