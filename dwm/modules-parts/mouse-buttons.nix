{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  commonVariables = (import ../common-variables.nix) { inherit lib config; };
  modifierType = commonVariables.modifierType;
in
{
  options.services.xserver.windowManager.dwm.config.buttons = mkOption {
    description = "The function to run when a mouse key is pressed.";
    type = types.listOf (
      types.submodule {
        options = {
          clickArea = mkOption {
            type = types.str;
            description = "Where the click occurs (e.g. ClkTagBar, ClkClientWin, ClkRootWin).";
            example = "ClkTagBar";
          };

          modifier = mkOption {
            type = modifierType;
            description = "Keyboard modifier key (e.g. 0, Mod1Mask, Mod4Mask, ShiftMask).";
            example = "MODKEY";
          };

          button = mkOption {
            type = types.str;
            description = "Mouse button (e.g. Button1, Button2, Button3).";
            example = "Button2";
          };

          function = mkOption {
            type = types.str;
            description = "Function to execute (e.g. view, toggleview, movemouse).";
            example = "toggleview";
          };

          argument = mkOption {
            type = types.str;
            description = "Argument for the function (e.g. {0}, {.i = 1}, {.ui = 1<<2}).";
            example = "{0}";
          };
        };
      }
    );
    default = [
      {
        clickArea = "ClkLtSymbol";
        modifier = "0";
        button = "Button1";
        function = "setlayout";
        argument = "{0}";
      }
      {
        clickArea = "ClkLtSymbol";
        modifier = "0";
        button = "Button3";
        function = "setlayout";
        argument = "{.v = &layouts[2]}";
      }
      {
        clickArea = "ClkWinTitle";
        modifier = "0";
        button = "Button2";
        function = "zoom";
        argument = "{0}";
      }
      {
        clickArea = "ClkStatusText";
        modifier = "0";
        button = "Button2";
        function = "spawn";
        argument = "{.v = termcmd}";
      }
      {
        clickArea = "ClkClientWin";
        modifier = "MODKEY";
        button = "Button1";
        function = "movemouse";
        argument = "{0}";
      }
      {
        clickArea = "ClkClientWin";
        modifier = "MODKEY";
        button = "Button2";
        function = "togglefloating";
        argument = "{0}";
      }
      {
        clickArea = "ClkClientWin";
        modifier = "MODKEY";
        button = "Button3";
        function = "resizemouse";
        argument = "{0}";
      }
      {
        clickArea = "ClkTagBar";
        modifier = "0";
        button = "Button1";
        function = "view";
        argument = "{0}";
      }
      {
        clickArea = "ClkTagBar";
        modifier = "0";
        button = "Button3";
        function = "toggleview";
        argument = "{0}";
      }
      {
        clickArea = "ClkTagBar";
        modifier = "MODKEY";
        button = "Button1";
        function = "tag";
        argument = "{0}";
      }
      {
        clickArea = "ClkTagBar";
        modifier = "MODKEY";
        button = "Button3";
        function = "toggletag";
        argument = "{0}";
      }
    ];
  };

}
