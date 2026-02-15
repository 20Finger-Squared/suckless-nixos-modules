{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkPackageOption
    mkEnableOption
    mkOption
    types
    literalExpression
    mkIf
    singleton
    ;

  common-variables = import ./common-variables.nix;
  cfg = common-variables.cfg;
  modifierType = common-variables.modifierType;

  file = pkgs.writeText "config.c" (
    (import ./file.nix) {
      inherit lib;
      inherit config;
    }
  );
in
{

  imports = [
    ./modules-parts/apps.nix
    ./modules-parts/colors.nix
    ./modules-parts/keys.nix
    ./modules-parts/layout.nix
    ./modules-parts/mouse-buttons.nix
    ./modules-parts/rules.nix
    ./modules-parts/tags.nix
  ];

  ###### interface
  options.services.xserver.windowManager.dwm = {
    enable = mkEnableOption "dwm";
    extraSessionCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands executed just before dwm is started.
      '';
    };
    package = mkPackageOption pkgs "dwm" {
      example = ''
        pkgs.dwm.overrideAttrs (oldAttrs: rec {
          patches = [
            (super.fetchpatch {
              url = "https://dwm.suckless.org/patches/steam/dwm-steam-6.2.diff";
              sha256 = "sha256-f3lffBjz7+0Khyn9c9orzReoLTqBb/9gVGshYARGdVc=";
            })
          ];
        })
      '';
    };
    config = {
      enable = mkEnableOption "configuration of dwm in Nix, toggleable as this compiles on your machine";
      finalPackage = mkOption {
        type = types.package;
        readOnly = true;
        defaultText = literalExpression ''
          cfg.package.overrideAttrs (oldAttrs: {
            postPatch = "cp ''${file} config.h; cp ''${file} config.def.h";
          })
        '';
        default =
          let
            finalPackage = cfg.package.overrideAttrs (oldAttrs: {
              postPatch = "cp ${file} config.h; cp ${file} config.def.h";
            });
          in
          finalPackage;
        description = ''
          The final dwm package, with the config applied.
        '';
      };

      showBar = mkOption {
        description = "Whether to show bar on screen.";
        type = types.bool;
        default = true;
        example = false;
      };

      topBar = mkOption {
        description = "Whether the bar is on top.";
        type = types.bool;
        default = true;
        example = false;
      };

      font = {
        name = mkOption {
          description = "The given name for the font.";
          type = types.str;
          default = "monospace";
          example = "JetbrainsMono NF";
        };
        size = mkOption {
          type = types.int;
          default = 10;
          example = 12;
          description = "The font size.";
        };
      };

      file = {
        prepend = mkOption {
          description = "Custom C code to prepend to the file.";
          type = types.str;
          default = "";
        };
        append = mkOption {
          description = "Custom C code to append to the file.";
          type = types.str;
          default = "";
        };
      };

      borderpx = mkOption {
        description = "Border pixel width of windows.";
        type = types.int;
        default = 1;
        example = 5;
      };

      modifier = mkOption {
        description = "The default modifier for keybinds.";
        type = modifierType;
        default = "Mod1Mask";
        example = "Mod4Mask";
      };

      snap = mkOption {
        description = "Snap pixel.";
        type = types.int;
        default = 32;
        example = 16;
      };
    };
  };
  ###### implementation
  config = mkIf cfg.enable {
    services.xserver.windowManager.session = singleton {
      name = "dwm";
      start = ''
        ${cfg.extraSessionCommands}

        export _JAVA_AWT_WM_NONREPARENTING=1
        dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      (if cfg.config.enable then cfg.config.finalPackage else cfg.package)
    ];
  };

  meta.maintainers = with lib.maintainers; [
    twenty-finger-squared
  ];
}
