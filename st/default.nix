{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    types
    mkIf
    ;

  file = pkgs.writeText "config.h" (
    import ./file.nix {
      inherit lib;
      inherit config;
    }
  );
in
{
  options.programs.st = {
    enable = mkEnableOption "st";
    package = mkPackageOption pkgs "st" {
      default = "st";
    };
    final-package = mkOption {
      readOnly = true;
      type = types.package;
      default = (
        config.programs.st.package.overrideAttrs (oldAttrs: {
          postPatch = "cp ${file} config.def.h";
        })
      );
    };
    borderpx = mkOption {
      description = "The width of the border in pixels.";
      type = types.int;
      default = 2;
      example = 0;
    };
    shell = mkOption {
      description = "The shell to use.";
      type = types.str;
      default = "/bin/sh";
      example = literalExpression "${lib.getExe pkgs.bash}";
    };
    utmp = mkOption {
      description = "The name for the terminal session inside system login records.";
      type = types.nullOr types.str;
      default = null;
      example = literalExpression "${lib.getExe pkgs.utmp}";
    };
    scroll = mkOption {
      description = "The scroll program: to enable use a string like \"scroll\"";
      type = types.nullOr types.str;
      default = null;
      example = "scroll";
    };
    word-delimiters = mkOption {
      description = "When to break word selection.";
      type = types.str;
      default = " ";
      example = "`'\"()[]{}";
    };
    bell-volume = mkOption {
      description = "Bell volume in a range of -100 to 100. Use 0 to mute.";
      type = types.ints.between (-100) 100;
      default = 0;
      example = 100;
    };
    terminal-name = mkOption {
      description = "The default TERM value";
      type = types.str;
      default = "st-256color";
      example = "TERM";
    };
    tab-spaces = mkOption {
      description = "How many spaces a tab should expand into.";
      type = types.int;
      default = 8;
      example = 2;
    };
    internal-mouse-shortcuts = {
      use-default = mkOption {
        description = "Whether to use the default keybinds (recomended).";
        type = types.bool;
        default = true;
        example = false;
      };

      binds = mkOption {
        description = ''
          Internal mouse shortcuts.
          Beware that overloading Button1 will disable the selection.
        '';
        type = types.listOf (
          types.submodule {
            options = {
              mask = mkOption {
                description = "The modifier mask.";
                type = types.str;
                example = "XK_ANY_MOD";
              };
              button = mkOption {
                description = "The mouse button.";
                type = types.str;
                example = "Button2";
              };
              function = mkOption {
                description = "The function to call.";
                type = types.str;
                example = "ttysend";
              };
              argument = mkOption {
                description = "The argument to pass to the function.";
                type = types.either types.int types.str;
                example = "\\031";
              };
              release = mkOption {
                description = "Whether to trigger on mouse release.";
                type = types.bool;
                example = true;
              };
            };
          }
        );
        default = [ ];
      };
    };
    modifier = mkOption {
      description = "The default modifier";
      type = types.either types.str (types.enum [ 0 ]);
      default = "Mod1Mask";
      example = 0;
    };
    ignore-mod = mkOption {
      description = ''
        State bits to ignore when matching key or button events.  By default,
        numlock (Mod2Mask) and keyboard layout (XK_SWITCH_MOD) are ignored.
      '';
      type = types.str;
      default = "Mod2Mask|XK_SWITCH_MOD";
    };
    mapped-keys = mkOption {
      description = ''
        If you want keys other than the X11 function keys (0xFD00 - 0xFFFF)
        to be mapped below, add them to this array.
      '';
      type = types.listOf types.int;
      default = [ (-1) ];
    };
    shortcuts = {
      use-default = mkOption {
        description = "Whether to use the default keybinds.";
        type = types.bool;
        default = true;
        example = false;
      };
      binds = mkOption {
        description = "The binding for the shortcuts";
        type = types.listOf (
          types.submodule {
            options = {
              mask = mkOption {
                description = "The modifier mask.";
                type = types.str;
                example = "XK_ANY_MOD";
              };
              keysym = mkOption {
                description = "The key symbol.";
                type = types.str;
                example = "XK_Break";
              };
              function = mkOption {
                description = "The function to call.";
                type = types.str;
                example = "clipcopy";
              };
              argument = mkOption {
                description = "The argument to pass to the function.";
                type = types.either types.int types.float;
                example = 0;
              };
            };
          }
        );
        default = [ ];
      };
    };
    force-mouse-mod = mkOption {
      description = ''
        Force mouse select/shortcuts while mask is active (when MODE_MOUSE is set).
        Note that if you want to use ShiftMask with selmasks, set this to an other
        modifier, set to 0 to not use it.
      '';
      type = types.either (types.enum [ 0 ]) types.str;
      default = "ShiftMask";
      example = 0;
    };
    default-attr = mkOption {
      description = ''
        The index of the colour used to display font attributes when fontconfig selected a font which
        doesn't match the ones requested.
      '';
      type = types.int;
      default = 11;
    };
    mouse = {
      shape = mkOption {
        description = "The shape of the mouse cursor.";
        type = types.str;
        default = "XC_xterm";
      };
      fg = mkOption {
        description = "The foreground colour index of the mouse cursor.";
        type = types.int;
        default = 7;
      };
      bg = mkOption {
        description = "The background colour index of the mouse cursor.";
        type = types.int;
        default = 0;
      };
    };
    terminal-size = {
      rows = mkOption {
        description = "The default amount of rows";
        type = types.int;
        default = 24;
        example = 30;
      };
      columns = mkOption {
        description = "The default amount of columns";
        type = types.int;
        default = 80;
        example = 60;
      };
    };
    cursor-shape = mkOption {
      description = ''
        Default shape of cursor
        2: Block ("█")
        4: Underline ("_")
        6: Bar ("|")
        7: Snowman ("☃")'';
      type = types.int;
      default = 2;
      example = 6;
    };
    cursor-thickness = mkOption {
      description = "thickness of underline and bar cursors";
      type = types.int;
    };
    color-name =
      let
        mkColourOption =
          desc: def:
          mkOption {
            description = desc;
            type = types.listOf types.str;
            default = def;
          };
      in
      {
        advanced = {
          default-fg = mkOption {
            description = "The default foreground index.";
            type = types.int;
            default = 258;
          };
          default-bg = mkOption {
            description = "The default background index.";
            type = types.int;
            default = 259;
          };
          default-cs = mkOption {
            description = "The default cursor colour index.";
            type = types.int;
            default = 256;
          };
          default-rcs = mkOption {
            description = "The default reverse cursor colour index.";
            type = types.int;
            default = 257;
          };
        };
        foreground = mkOption {
          description = "The default foreground colour.";
          type = types.str;
          default = "gray90";
        };
        background = mkOption {
          description = "The default background colour.";
          type = types.str;
          default = "black";
        };
        normal = mkColourOption "The normal colours to use." [
          "black"
          "red3"
          "green3"
          "yellow3"
          "blue2"
          "magenta3"
          "cyan3"
          "gray90"
        ];
        bright = mkColourOption "The bright colours to use." [
          "gray50"
          "red"
          "green"
          "yellow"
          "#5c5cff"
          "magenta"
          "cyan"
          "white"
        ];
        extra = mkColourOption "Extra colours to use." [
          "#cccccc"
          "#555555"
        ];
      };
    latency = {
      min = mkOption {
        description = "The draw latency lower range in ms";
        type = types.int;
        default = 2;
        example = 4;
      };
      max = mkOption {
        description = "The draw latency upper range in ms";
        type = types.int;
        default = 33;
        example = 35;
      };
    };
    blink-timeout = mkOption {
      description = ''
        blinking timeout (set to 0 to disable blinking) for the terminal blinking
        attribute.
      '';
      type = types.int;
      default = 800;
      example = 400;
    };
    window-ops = mkEnableOption ''
      allow certain non-interactive (insecure) window operations such as:
      setting the clipboard text'';
    alt-screen = mkOption {
      description = "Whether to enable alternative screen buffers.";
      type = types.bool;
      default = true;
      example = false;
    };
    selection-timeouts = {
      double-click = mkOption {
        description = "When to timeout a double click (in milliseconds).";
        type = types.int;
        default = 300;
        example = 150;
      };
      triple-click = mkOption {
        description = "When to timeout a triple click (in milliseconds).";
        type = types.int;
        default = 600;
        example = 300;
      };
    };
    advanced-options = {
      kerning = {
        width = mkOption {
          description = "A multiplier of the width of the character bounding box.";
          type = types.float;
          default = 1.0;
        };
        height = mkOption {
          description = "A multiplier of the height of the character bounding box.";
          type = types.float;
          default = 1.0;
        };
      };
      stty-args = mkOption {
        description = "The args given to the tty interface.";
        type = types.str;
        default = "stty raw pass8 nl -echo -iexten -cstopb 38400";
      };
      vtiden = mkOption {
        description = "What st reports itself to be emulating.";
        type = types.str;
        default = "\\033[?6c";
      };
    };
    font = {
      name = mkOption {
        description = "The name of the font you wish to use.";
        type = types.str;
        default = "Liberation Mono";
        example = "JetbrainsMono NF";
      };
      size = mkOption {
        description = "The size of the font in pixel size.";
        type = types.int;
        default = 12;
        example = 18;
      };
      antialias = mkOption {
        description = "Whether to enable antialiasing.";
        type = types.bool;
        default = true;
        example = false;
      };
      autohint = mkOption {
        description = "Whether to enable autohints.";
        type = types.bool;
        default = true;
        example = false;
      };
    };
    key-mappings = {
      use-default = mkOption {
        description = "Whether to use the default key compatibility mappings (recommended).";
        type = types.bool;
        default = true;
        example = false;
      };
      binds = mkOption {
        description = "Key mappings for Linux terminal compatibility.";
        type = types.listOf (
          types.submodule {
            options = {
              keysym = mkOption {
                description = "The key symbol.";
                type = types.str;
                example = "XK_KP_Home";
              };
              mask = mkOption {
                description = "The modifier mask.";
                type = types.str;
                example = "ShiftMask";
              };
              string = mkOption {
                description = "The string to send.";
                type = types.str;
                example = "\\033[2J";
              };
              appkey = mkOption {
                description = "Application keypad state: +1 active, -1 inactive, 0 any.";
                type = types.ints.between (-2) 2;
                example = 1;
              };
              appcursor = mkOption {
                description = "Application cursor state: +1 active, -1 inactive, 0 any.";
                type = types.ints.between (-1) 1;
                example = 1;
              };
            };
          }
        );
        default = [ ];
      };
    };
    sel-masks = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              description = "The mask to set the modifier for.";
              type = types.str;
            };
            modifier = mkOption {
              description = "The modifier mask for rectangular selection.";
              type = types.str;
            };
          };
        }
      );
      default = [
        {
          name = "SEL_RECTANGULAR";
          modifier = "Mod1Mask";
        }
      ];
    };
    ascii-printable = mkOption {
      description = ''
        Printable characters in ASCII, used to estimate the advance width
        of single wide characters.
      '';
      type = types.str;
      default = " !\\\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
    };
  };
  config = mkIf config.programs.st.enable {
    environment.systemPackages = [ config.programs.st.final-package ];
  };
}
