{ config, lib }:
with lib;
let
  cfg = config.programs.dwm;
  tagkey-definition =
    import
      (
        if cfg.patches.keymodes.enable then
          ./file-parts/tags/keymodes.nix
        else
          ./file-parts/tags/default.nix
      )
      {
        inherit config;
        inherit lib;
      };
in
/* c */ ''
  ${cfg.file.prepend}
  #define MODKEY ${if builtins.isString cfg.modifier then cfg.modifier else toString cfg.modifier}
  #define TAGKEYS(KEY, TAG) \
    ${tagkey-definition}
  #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
  static const unsigned int borderpx = ${toString cfg.borderpx};
  static const unsigned int gappx    = ${toString cfg.patches.gaps.width};
  static const unsigned int snap     = ${toString cfg.snap};
  static const int showbar           = ${if cfg.showBar then "1" else "0"};
  static const int topbar            = ${if cfg.topBar then "1" else "0"};
  static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
  static const char *fonts[]         = { "${cfg.font.name}:size=${toString cfg.font.size}" };

  /* layout(s) */
  static const float mfact        = ${toString cfg.layout.mfact}; /* factor of master area size [0.05..0.95] */
  static const int nmaster        = ${toString cfg.layout.nmaster};    /* number of clients in master area */
  static const int resizehints    = ${toString cfg.layout.resizehints};    /* 1 means respect size hints in tiled resizals */
  static const int lockfullscreen = ${toString cfg.layout.lockfullscreen}; /* 1 will force focus on the fullscreen window */

  static const char *colors[][3] = { ${
    concatMapStringsSep ",\n" (pair: ''
      [ ${pair.name} ] = { "${pair.value.fg}", "${pair.value.bg}", "${pair.value.border}" }
    '') (mapAttrsToList (name: value: { inherit name value; }) cfg.colors)
  },
  ${optionalString (cfg.patches.keymodes.scheme.enable && cfg.patches.keymodes.enable)
    ''[SchemeCommandMode] = { "${cfg.patches.keymodes.scheme.fg}", "${cfg.patches.keymodes.scheme.bg}", "${cfg.patches.keymodes.scheme.border}" }''
  }
   };

  ${
    let
      appArgs =
        x:
        if x == [ ] then
          ""
        else
          concatMapStringsSep " " (
            arg: ''"${toString arg.flag}" ${toString (optional (arg.argument != null) ",${arg.argument}")},''
          ) x;
    in
    ''
      static const char *dmenucmd[] = { "${cfg.appLauncher.appCmd}",
        ${appArgs cfg.appLauncher.appArgs}
        NULL };

      static const char *termcmd[]  = { "${cfg.terminal.appCmd}",
        ${appArgs cfg.terminal.appArgs}
        NULL };
    ''
  }

  static const char *tags[] = { ${concatMapStringsSep ", " (tag: ''"${toString tag}"'') cfg.tags} };

  static const Layout layouts[] = {
  ${concatMapStringsSep ",\n " (
    layout: ''{"${layout.symbol}", ${layout.arrangeFunction}}''
  ) cfg.layout.layouts}
  };

  static const Rule rules[] = {
  ${concatMapStringsSep ",\n " (rule: ''
    {
    "${rule.class}", ${rule.instance}, ${rule.title}, ${toString rule.tagsMask}, ${
      if rule.isFloating then "1" else "0"
    }, ${toString rule.monitor}
    }
  '') cfg.rules}
  };

  static const Key keys[] = {
      ${
        (import ./file-parts/keys/default.nix {
          inherit lib;
          inherit config;
        })
      }
      ${optionalString cfg.patches.keymodes.enable (
        import ./file-parts/keys/keymodes.nix {
          inherit lib;
          inherit config;
        }
      )}
  };
  static const Button buttons[] = {
      ${
        concatMapStringsSep ",\n        " (
          button: ''{${button.click},${button.mask},${button.button},${button.function},${button.argument}}''
        ) cfg.buttons
      },
  };

  ${optionalString (cfg.patches.keymodes.enable) (
    import ./file-parts/custom-parts/keymodes.nix {
      inherit lib;
      inherit config;
    }
  )}
  ${optionalString (cfg.patches.cool-autostart.enable) (
    import ./file-parts/custom-parts/cool-autostart.nix {
      inherit lib;
      inherit config;
    }
  )}
  ${cfg.file.append}
''
