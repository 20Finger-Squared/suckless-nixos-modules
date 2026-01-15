{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  types = lib.types // {
    hexColor = types.strMatching "^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$";
  };
  cfg = config.programs.dmenu;
  file = pkgs.writeText "config.def.h" /* c */ ''
    /* See LICENSE file for copyright and license details. */
    /* Default settings; can be overriden by command line. */
    static int topbar = ${
      if cfg.topbar then "1" else "0"
    }; /* -b  option; if 0, dmenu appears at bottom     */
    /* -fn option overrides fonts[0]; default X11 font or font set */
    static const char *fonts[]         = { "${cfg.font.name}:size=${toString cfg.font.size}" };
    static const char *prompt      = ${cfg.prompt};      /* -p  option; prompt to the left of input field */
    static int centered = ${if cfg.patches.centered.centered then "1" else "0"};
    static int min_width = ${toString cfg.patches.centered.min_width};
    static const float menu_height_ratio = ${toString cfg.patches.centered.menu_height_ratio}f;
    static const char *colors[SchemeLast][2] = {
        ${
          let
            colorLines = lib.mapAttrsToList (
              name: value: "[ ${name} ] = { \"${value.fg}\", \"${value.bg}\" }"
            ) cfg.colors;
            promptLine =
              if cfg.patches.inlinePrompt.enable then
                [
                  "[ SchemePrompt ] = { \"${cfg.patches.inlinePrompt.schemePrompt.fg}\", \"${cfg.patches.inlinePrompt.schemePrompt.bg}\" }"
                ]
              else
                [ ];
          in
          concatStringsSep ",\n        " (colorLines ++ promptLine)
        }
    };
    /* -l option; if nonzero, dmenu uses vertical list with given number of lines */
    static unsigned int lines = ${toString cfg.lines};
    /*
     * Characters not considered part of a word while deleting words
     * for example: " /?\"&[]"
     */
    static const char worddelimiters[] = "${cfg.wordDelimiters}";
  '';
  dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: {
    postPatch = ''
      sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
      cp ${file} config.def.h
    '';
    patches =
      (if oldAttrs.patches == null then [ ] else oldAttrs.patches)
      ++ (if (cfg.patches.inlinePrompt.enable) then [ ./inline-prompt.diff ] else [ ])
      ++ (if (cfg.patches.centered.enable) then [ ./center.diff ] else [ ]);
  });
in
{
  options.programs.dmenu = {
    enable = mkEnableOption "dmenu";
    topbar = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the bar being on the top of the display";
    };

    wordDelimiters = mkOption {
      type = types.str;
      default = " ";
      description = "Characters not considered part of a word while deleting words";
    };
    lines = mkOption {
      type = types.int;
      default = 0;
      example = 5;
      description = "Number of lines for vertical list (0 for horizontal)";
    };
    prompt = mkOption {
      type = types.str;
      default = "NULL";
      example = "\"run\"";
      description = "Prompt text to display";
    };
    font = {
      name = mkOption {
        type = types.str;
        default = "monospace";
        example = "JetbrainsMono NF";
        description = "Font family for dmenu";
      };
      size = mkOption {
        type = types.int;
        default = 10;
        example = 12;
        description = "Font size for dmenu";
      };
    };
    colors =
      mapAttrs
        (
          name: default:
          mkOption {
            type = types.submodule {
              options = {
                fg = mkOption { type = types.hexColor; };
                bg = mkOption { type = types.hexColor; };
                border = mkOption { type = types.hexColor; };
              };
            };
            inherit default;
          }
        )
        {
          SchemeNorm = {
            fg = "#bbbbbb";
            bg = "#222222";
          };
          SchemeSel = {
            fg = "#eeeeee";
            bg = "#005577";
          };
          SchemeOut = {
            fg = "#000000";
            bg = "#00ffff";
          };
        };

    patches = {
      customPatches = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = "Custom patches to apply to dmenu";
      };
      centered = {
        enable = mkEnableOption "centered dmenu patch";
        centered = mkOption {
          type = types.bool;
          default = true;
          description = "Whether the dmenu prompt is centered by default";
        };
        min_width = mkOption {
          type = types.int;
          default = 500;
          description = "minimum width when centered";
        };
        menu_height_ratio = mkOption {
          type = types.float;
          default = 4.0;
          description = "This is the ratio used in the original calculation";
        };
      };
      inlinePrompt = {
        enable = mkEnableOption "inline prompt patch";
        schemePrompt = mkOption {
          type = types.submodule {
            options = {
              fg = mkOption {
                type = types.str;
                description = "Foreground color for prompt";
              };
              bg = mkOption {
                type = types.str;
                description = "Background color for prompt";
              };
            };
          };
          default = {
            fg = "#444444";
            bg = "#222222";
          };
          description = "Color scheme for inline prompt";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    system.build.dmenu-config = file;
    environment.systemPackages = [
      dmenu
    ];
  };
}
