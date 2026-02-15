{ lib, ... }:
let
  inherit (lib) mkOption types literalExpression;
in
{
  options.services.xserver.windowManager.dwm.config.layout = {
    mfact = mkOption {
      description = "Factor of master area size [0.05..0.95].";
      type = types.float;
      default = 0.55;
      example = 0.70;
    };
    nmaster = mkOption {
      description = "Number of clients in master area by default.";
      type = types.int;
      default = 1;
      example = 2;
    };

    resizehints = mkOption {
      description = "Whether to respect size hints in tiled resizing.";
      type = types.bool;
      default = true;
      example = false;
    };
    lockfullscreen = mkOption {
      description = "Whether to force focus on the fullscreen window.";
      type = types.bool;
      default = true;
      example = false;
    };

    layouts = mkOption {
      description = "The layout definitions.";
      type = types.listOf (
        types.submodule {
          options = {
            symbol = mkOption {
              description = "The icon for the layout such as '[]=' for tiling.";
              type = types.str;
              example = "[]=";
            };
            arrangeFunction = mkOption {
              description = "The function that changes the tiling mode.";
              type = types.str;
              example = "tile";
            };
          };
        }
      );
      default = [
        {
          symbol = "[]=";
          arrangeFunction = "tile";
        }
        {
          symbol = "><>";
          arrangeFunction = "NULL";
        }
        {
          symbol = "[M]";
          arrangeFunction = "monocle";
        }
      ];
      example = literalExpression ''{ symbol = "[=]"; arrageFunction = "tile"; }'';
    };
  };

}
