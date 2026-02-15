{ lib, config, ... }:
let
  inherit (lib) types mkOption;
  commonVariables = (import ../common-variables.nix) { inherit lib config; };
  modifierType = commonVariables.modifierType;
in
{
  options.services.xserver.windowManager.dwm.config = {
    tags = mkOption {
      description = "The workspace numbers or 'tags'.";
      type = types.listOf types.int;
      default = [
        1
        2
        3
        4
        5
        6
        7
        8
        9
      ];
      example = [
        1
        2
        3
      ];
    };
    tagKeys = {
      modifiers = {
        viewOnlyThisTag = mkOption {
          description = "Move to this tag.";
          type = modifierType;
          default = "MODKEY";
          example = "MODKEY";
        };
        toggleThisTagInView = mkOption {
          description = "Show this tag plus the current.";
          type = modifierType;
          default = "MODKEY|ControlMask";
          example = "MODKEY";
        };
        moveWindowToThisTag = mkOption {
          description = "Move focused window to this tag.";
          type = modifierType;
          default = "MODKEY|ShiftMask";
          example = "MODKEY";
        };
        toggleWindowOnThisTag = mkOption {
          description = "Show the focused window in the tag";
          type = modifierType;
          default = "MODKEY|ControlMask|ShiftMask";
          example = "MODKEY";
        };
      };

      definitions = mkOption {
        description = "The definitions for binding a keybind to a tag";
        type = types.listOf (
          types.submodule {
            options = {
              key = mkOption {
                description = "The hex or x11 keybind to press alongside the modifier.";
                type = types.str;
                example = "XK_9";
              };
              tag = mkOption {
                description = "The tag to assign to the key.";
                type = types.int;
                example = 9;
              };
            };
          }
        );

        default = [
          {
            key = "XK_1";
            tag = 1;
          }
          {
            key = "XK_2";
            tag = 2;
          }
          {
            key = "XK_3";
            tag = 3;
          }
          {
            key = "XK_4";
            tag = 4;
          }
          {
            key = "XK_5";
            tag = 5;
          }
          {
            key = "XK_6";
            tag = 6;
          }
          {
            key = "XK_7";
            tag = 7;
          }
          {
            key = "XK_8";
            tag = 8;
          }
          {
            key = "XK_9";
            tag = 9;
          }
        ];
      };
    };

  };
}
