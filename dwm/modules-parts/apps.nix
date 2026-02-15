{ lib, config, ... }:
let
  inherit (lib) mkOption types literalExpression;
  commonVariables = (import ../common-variables.nix) { inherit lib config; };
  modifierType = commonVariables.modifierType;
in
{
  options.services.xserver.windowManager.dwm.config = {
    appLauncher = {
      modifier = mkOption {
        description = "The modifier to press alongside the key to launch the app launcher.";
        type = modifierType;
        default = "MODKEY";
        example = "0";
      };
      launchKey = mkOption {
        description = "The key to press alongside the modifier to launch the app launcher.";
        type = types.str;
        default = "XK_p";
        example = "XK_a";
      };
      appCmd = mkOption {
        description = "The application launcher command.";
        type = types.str;
        default = "dmenu_run";
        example = "rofi";
      };
      appArgs = mkOption {
        description = ''
          Arguments to pass to the application launcher command.
          Dmenumon is a variable that contains the current monitor that dmenu should spawn.
          You can use this variable inside other app launchers.
        '';
        type = types.listOf (
          types.submodule {
            options = {
              flag = mkOption {
                type = types.str;
                description = "The flag or argument name.";
                example = "-m";
              };
              argument = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "The value for the flag.";
                example = "0";
              };
            };
          }
        );
        example = literalExpression ''[ { flag = "-show"; argument = "drun"; } ]'';
        default = [
          {
            flag = "-m";
            argument = "dmenumon";
          }
          {
            flag = "-fn";
            argument = ''
              "monospace:size=10"
            '';
          }
          {
            flag = "-nb";
            argument = ''
              "#222222"
            '';
          }
          {
            flag = "-nf";
            argument = ''
              "#bbbbbb"
            '';
          }
          {
            flag = "-sb";
            argument = ''
              "#005577"
            '';
          }
          {
            flag = "-sf";
            argument = ''
              "#eeeeee"
            '';
          }
        ];
      };
    };

    terminal = {
      modifier = mkOption {
        description = "The modifier to press alongside the launchKey to launch the terminal";
        type = modifierType;
        default = "MODKEY|ShiftMask";
        example = "0";
      };
      launchKey = mkOption {
        description = "The key to press alongside the modifier to launch the terminal";
        type = types.str;
        default = "XK_Return";
        example = "XK_t";
      };

      appCmd = mkOption {
        description = "The terminal command to launch.";
        type = types.str;
        default = "st";
        example = "kitty";
      };
      appArgs = mkOption {
        description = "Arguments to pass to the terminal command.";
        type = types.listOf (
          types.submodule {
            options = {
              flag = mkOption {
                type = types.str;
                description = "The flag or argument name.";
                example = "-fn";
              };
              argument = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "The value for the flag. Null for a flag that does not require an argument";
                example = "monospace:size=12";
              };
            };
          }
        );
        default = [ ];
        example = literalExpression ''[ { flag = "-f"; argument = "monospace:size=12"; } ]'';
      };
    };
  };
}
