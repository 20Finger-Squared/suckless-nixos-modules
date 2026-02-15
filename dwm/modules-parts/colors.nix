{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.services.xserver.windowManager.dwm.config.colors = mkOption {
    description = "The colorschemes to use on dwm.";
    type = types.listOf (
      types.submodule {
        options = {
          name = mkOption {
            description = ''
              The name for the colourscheme, by default there are only two.
              'SchemeNorm' and 'SchemeSel'.
            '';
            type = types.str;
            example = "SchemeNorm";
          };
          fg = mkOption {
            description = "The foreground colour for the window.";
            type = types.str;
            example = "#ebdbb2";
          };
          bg = mkOption {
            description = "The background colour for the window.";
            type = types.str;
            example = "#282828";
          };
          border = mkOption {
            description = "The border colour for the window.";
            type = types.str;
            example = "#504945";
          };
        };
      }
    );
    default = [
      {
        name = "SchemeNorm";
        fg = "#bbbbbb";
        bg = "#222222";
        border = "#444444";
      }
      {
        name = "SchemeSel";
        fg = "#eeeeee";
        bg = "#005577";
        border = "#005577";
      }
    ];
  };
}
