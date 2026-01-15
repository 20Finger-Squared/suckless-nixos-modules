{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  types = lib.types // {
    hexColor = types.strMatching "^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$";
    modifier = types.strMatching "^(MODKEY|Mod[1-5]Mask|ShiftMask|ControlMask|LockMask|XK_SWITCH_MOD)(\\|(MODKEY|Mod[1-5]Mask|ShiftMask|ControlMask|LockMask|XK_SWITCH_MOD))*$";
  };

  file = pkgs.writeText "config.h" (
    import ./file.nix {
      inherit lib;
      inherit config;
    }
  );

  package = pkgs.st.overrideAttrs (oldAttrs: {
    postPatch = "cp ${file} config.def.h";
  });
in
{
  options.programs.st = {
    enable = mkEnableOption "st";
    borderpx = mkOption {
      type = types.int;
      default = 2;
      example = 0;
      description = "The width of borders in pixels";
    };

    shell = mkOption {
      type = types.str;
      default = "${pkgs.bash}/bin/sh";
      example = "${pkgs.tmux}/bin/sh";
      description = "The cmd initially executed on start-up";
    };

    allowaltscreen = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Enables things like vim to create a screen over your terminal
        best to be turned on unless you prefer how the tty by default does it.'';
    };

    cursorThickness = mkOption {
      type = types.int;
      default = 2;
      example = 3;
      description = "thickness of underline and bar cursors";
    };

    bellvolume = mkOption {
      type = types.ints.between (-100) 100;
      default = 0;
      example = 100;
      description = "bell volume. It must be a value between -100 and 100. Use 0 for disabling it";
    };

    tabSpaces = mkOption {
      type = types.int;
      default = 8;
      example = 2;
      description = "To how many spaces tabs are expanded to";
    };

    terminalName = mkOption {
      type = types.str;
      default = "st-256color";
      example = "terminal-256color";
      description = "The default window name for st";
    };

    blinking = mkOption {
      type = types.int;
      default = 800;
      example = 0;
      description = "blinking timeout (set to 0 to disable blinking) for the terminal blinking attribute.";
    };

    latency = {
      min = mkOption {
        type = types.int;
        default = 2;
        example = 3;
        description = "minimum latency for screen to be drawn";
      };
      max = mkOption {
        type = types.int;
        default = 33;
        example = 14;
        description = "maximum latency for screen to be drawn";
      };
    };

    allowwindowops = mkEnableOption ''escape sequences. This is off by default for security.'';

    asciiPrintable = mkOption {
      type = types.str;
      default = ''!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'';
      description = ''
        Printable characters in ASCII, used to estimate the advance width
        of single wide characters.
      '';
    };

    color = {
      colors = {
        normal = {
          red = mkOption {
            type = types.str;
            default = "red3";
          };
          green = mkOption {
            type = types.str;
            default = "green3";
          };
          yellow = mkOption {
            type = types.str;
            default = "yellow3";
          };
          blue = mkOption {
            type = types.str;
            default = "blue2";
          };
          magenta = mkOption {
            type = types.str;
            default = "magenta3";
          };
          cyan = mkOption {
            type = types.str;
            default = "cyan3";
          };
          white = mkOption {
            type = types.str;
            default = "gray90";
          };
          black = mkOption {
            type = types.str;
            default = "black";
          };
        };
        bright = {
          red = mkOption {
            type = types.str;
            default = "red";
          };
          green = mkOption {
            type = types.str;
            default = "green";
          };
          yellow = mkOption {
            type = types.str;
            default = "yellow";
          };
          blue = mkOption {
            type = types.str;
            default = "#5c5cff";
          };
          magenta = mkOption {
            type = types.str;
            default = "magenta";
          };
          cyan = mkOption {
            type = types.str;
            default = "cyan";
          };
          white = mkOption {
            type = types.str;
            default = "white";
          };
          black = mkOption {
            type = types.str;
            default = "gray50";
          };
        };
      };
      fg = mkOption {
        type = types.str;
        default = "gray90";
        example = "black";
      };
      bg = mkOption {
        type = types.str;
        default = "black";
        example = "white";
      };
      cursor = mkOption {
        type = types.str;
        default = "#cccccc";
        example = "#555555";
      };
      reverseCursor = mkOption {
        type = types.str;
        default = "#555555";
        example = "#cccccc";
      };
    };

    cursorShape = mkOption {
      type = types.int;
      default = 2;
      example = 7;
      description = ''
        Default shape of cursor
        2: Block ("█")
        4: Underline ("_")
        6: Bar ("|")
        7: Snowman ("☃")
      '';
    };

    selMasks = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Selection mask name (e.g., SEL_RECTANGULAR)";
            };
            value = mkOption {
              type = types.modifier;
              description = "Modifier mask value";
            };
          };
        }
      );
      default = [
        {
          name = "SEL_RECTANGULAR";
          value = "Mod1Mask";
        }
      ];
      description = "Selection masks";
    };

    modifier = {
      ignoreMod = mkOption {
        type = types.modifier;
        default = "Mod2Mask|XK_SWITCH_MOD";
      };
      termMod = mkOption {
        type = types.modifier;
        default = "ControlMask|ShiftMask";
        example = "Mod4Mask";
      };
      modkey = mkOption {
        type = types.modifier;
        default = "Mod1Mask";
        example = "ShiftMask";
      };
      forceMouse = mkOption {
        type = types.modifier;
        default = "ShiftMask";
        example = "Mod1Mask";
      };
    };

    shortcuts = {
      useDefault = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether to add the default shortcuts to the list of shortcuts";
      };
      mouse = {
        useDefault = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = "Whether to add the default mouse shortcuts to the list of shortcuts";
        };
        binds = mkOption {
          default = [ ];
          type = types.listOf (
            types.submodule {
              options = {
                modifier = mkOption {
                  type = types.modifier;
                  default = "XK_ANY_MOD";
                  example = "TERMMOD";
                };
                button = mkOption {
                  type = types.str;
                  default = "XK_Break";
                  example = "XK_C";
                };
                function = mkOption {
                  type = types.str;
                  default = "sendbreak";
                  example = "printscreen";
                };
                argument = mkOption {
                  type = types.str;
                  default = ".i = 0";
                  example = "0";
                };
                release = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  example = true;
                };
              };
            }
          );
        };
      };
      binds = mkOption {
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              modifier = mkOption {
                type = types.modifier;
                default = "XK_ANY_MOD";
                example = "TERMMOD";
              };
              keysym = mkOption {
                type = types.str;
                default = "XK_Break";
                example = "XK_C";
              };
              function = mkOption {
                type = types.str;
                default = "sendbreak";
                example = "printscreen";
              };
              argument = mkOption {
                type = types.str;
                default = ".i = 0";
                example = "0";
              };
            };
          }
        );
      };
    };

    key = {
      useDefault = mkOption {
        default = true;
        type = types.bool;
        example = true;
        description = ''Enable the default st keys: WARNING turning this off may render st inoperable'';
      };

      keys = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              keysym = mkOption {
                type = types.str;
                description = "X11 keysym (e.g., XK_KP_Home)";
              };
              mask = mkOption {
                type = types.modifier;
                description = "Modifier mask";
              };
              string = mkOption {
                type = types.str;
                description = "Output string";
              };
              appkey = mkOption {
                type = types.int;
                default = 0;
                description = "Application key mode";
              };
              appcursor = mkOption {
                type = types.int;
                default = -1;
                description = "Application cursor mode";
              };
            };
          }
        );
        default = [ ];
        description = "Dangerous key mappings";
      };

      description = ''
        This is the huge key array which defines all compatibility to the Linux
        world. Please decide about changes wisely.
      '';

    };

    mappedKeys = mkOption {
      type = types.listOf types.str;
      default = [ "-1" ];
      description = ''
        If you want keys other than the X11 function keys (0xFD00 - 0xFFFF)
        to be mapped below, add them to this array.
      '';
    };

    termSize = {
      rows = mkOption {
        type = types.int;
        default = 24;
      };
      columns = mkOption {
        type = types.int;
        default = 80;
      };
    };

    mouseShape = mkOption {
      type = types.str;
      default = "XC_xterm";
    };

    characterBox = {
      height = mkOption {
        type = types.float;
        default = 1.0;
        example = 5.0;
        description = "The character bounding box multiplier for the charcter's height";
      };
      width = mkOption {
        type = types.float;
        default = 1.0;
        example = 5.0;
        description = "The character bounding box multiplier for the charcter's width";
      };
    };

    clickTimeouts = {
      double = mkOption {
        type = types.int;
        default = 300;
        example = 150;
        description = "The selection timeouts for double clicking";
      };
      triple = mkOption {
        type = types.int;
        default = 600;
        example = 300;
        description = "The selection timeouts for triple clicking";
      };
    };

    font = {
      name = mkOption {
        type = types.str;
        default = "Liberation Mono";
        example = "monospace";
        description = "The name of the font";
      };
      size = mkOption {
        type = types.int;
        default = 12;
        example = 10;
        description = "The size of the font";
      };
      antialias = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether to enable antialias";
      };
      autohint = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether to enable autohint";
      };
    };
  };
  config = mkIf config.programs.st.enable {
    environment.systemPackages = [ package ];
  };
}
