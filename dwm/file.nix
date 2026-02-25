{ config, lib }:
let
  inherit (lib)
    mkIf
    zipListsWith
    optionalString
    optionals
    concatStringsSep
    concatMapStringsSep
    ;
  defaultKeys = [
    {
      modifier = "MODKEY";
      key = "XK_b";
      function = "togglebar";
      argument = "{0}";
    }
    {
      modifier = "MODKEY";
      key = "XK_j";
      function = "focusstack";
      argument = "{.i = +1 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_k";
      function = "focusstack";
      argument = "{.i = -1 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_i";
      function = "incnmaster";
      argument = "{.i = +1 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_d";
      function = "incnmaster";
      argument = "{.i = -1 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_h";
      function = "setmfact";
      argument = "{.f = -0.05}";
    }
    {
      modifier = "MODKEY";
      key = "XK_l";
      function = "setmfact";
      argument = "{.f = +0.05}";
    }
    {
      modifier = "MODKEY";
      key = "XK_Return";
      function = "zoom";
      argument = "{0}";
    }
    {
      modifier = "MODKEY";
      key = "XK_Tab";
      function = "view";
      argument = "{0}";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_c";
      function = "killclient";
      argument = "{0}";
    }
    {
      modifier = "MODKEY";
      key = "XK_t";
      function = "setlayout";
      argument = "{.v = &layouts[0]}";
    }
    {
      modifier = "MODKEY";
      key = "XK_f";
      function = "setlayout";
      argument = "{.v = &layouts[1]}";
    }
    {
      modifier = "MODKEY";
      key = "XK_m";
      function = "setlayout";
      argument = "{.v = &layouts[2]}";
    }
    {
      modifier = "MODKEY";
      key = "XK_space";
      function = "setlayout";
      argument = "{0}";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_space";
      function = "togglefloating";
      argument = "{0}";
    }
    {
      modifier = "MODKEY";
      key = "XK_0";
      function = "view";
      argument = "{.ui = ~0 }";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_0";
      function = "tag";
      argument = "{.ui = ~0 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_comma";
      function = "focusmon";
      argument = "{.i = -1 }";
    }
    {
      modifier = "MODKEY";
      key = "XK_period";
      function = "focusmon";
      argument = "{.i = +1 }";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_comma";
      function = "tagmon";
      argument = "{.i = -1 }";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_period";
      function = "tagmon";
      argument = "{.i = +1 }";
    }
    {
      modifier = "MODKEY|ShiftMask";
      key = "XK_q";
      function = "quit";
      argument = "{0}";
    }
  ];
  commonVariables = (import ./common-variables.nix) { inherit lib config; };
  cfg = commonVariables.cfg.config;
  boolToString = x: if x then "1" else "0";
  modToString = modifier: if (modifier != null) then (toString modifier) else "MODIFIER";
in
/* c */ ''
   ${cfg.file.prepend}
   static const unsigned int borderpx = ${toString cfg.borderpx};
   static const unsigned int snap     = ${toString cfg.snap};
   static const int showbar           = ${boolToString cfg.showBar};
   static const int topbar            = ${boolToString cfg.topBar};
   static const char *fonts[]         = { "${cfg.font.name}:size=${toString cfg.font.size}" };
   static const char *colors[][3] = {
   ${concatMapStringsSep "," (
     scheme: ''[${scheme.name}]={"${scheme.fg}", "${scheme.bg}", "${scheme.border}"}''
   ) cfg.colors}
   };

   static const char *tags[] = { ${concatMapStringsSep ", " (tag: ''"${toString tag}"'') cfg.tags} };

   static const Rule rules[] = {
   ${
     let
       valueToString = val: if val != null then ''"${toString val}"'' else "NULL";
     in
     concatMapStringsSep ", " (rule: ''
       {
       "${rule.class}", ${valueToString rule.instance}, ${valueToString rule.title}, ${
         if (rule.tag != null) then "1<<${toString (rule.tag - 1)}" else "0"
       }, ${boolToString rule.isFloating}, ${toString rule.monitor}
       }
     '') cfg.rules
   }
   };

   static const float mfact        = ${toString cfg.layout.mfact};
   static const int nmaster        = ${toString cfg.layout.nmaster};
   static const int resizehints    = ${boolToString cfg.layout.resizehints};
   static const int lockfullscreen = ${boolToString cfg.layout.lockfullscreen};

   static const Layout layouts[] = {
   ${concatMapStringsSep ",\n " (
     layout: ''{"${layout.symbol}", ${layout.arrangeFunction}}''
   ) cfg.layout.layouts}
   };

   #define MODKEY ${cfg.modifier}
   #define TAGKEYS(KEY, TAG) \
       {${cfg.tagKeys.modifiers.viewOnlyThisTag},       KEY, view,       {.ui = 1 << TAG} }, \
       {${cfg.tagKeys.modifiers.toggleThisTagInView},   KEY, toggleview, {.ui = 1 << TAG} }, \
       {${cfg.tagKeys.modifiers.moveWindowToThisTag},   KEY, tag,        {.ui = 1 << TAG} }, \
       {${cfg.tagKeys.modifiers.toggleWindowOnThisTag}, KEY, toggletag,  {.ui = 1 << TAG} },

   #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

   static char dmenumon[2] = "0";
   ${concatStringsSep "" (
     zipListsWith (keys: name: ''
       static const char *${name}[] = {
         "${keys.appCmd}",
         ${
           optionalString (keys.appArgs != [ ] && keys.appArgs != null) (
             concatMapStringsSep ", " (
               arg: ''"${toString arg.flag}"${optionalString (arg.argument != null) ", ${arg.argument}"}''
             ) keys.appArgs
             + ", "
           )
         }NULL
       };
     '') [ cfg.appLauncher cfg.terminal ] [ "dmenucmd" "termcmd" ]
   )}
   static const Key keys[] = {
   ${
     let
       # generate keybindings for the terminal and app launcher
       appKeys = zipListsWith (key: cmd: {
         modifier = modToString key.modifier;
         key = key.launchKey;
         function = "spawn";
         argument = "{.v=${cmd}}";
       }) [ cfg.terminal cfg.appLauncher ] [ "termcmd" "dmenucmd" ];
     in
     # create default key bindings before user defined bindings
     concatMapStringsSep ",\n" (
       key: "{${modToString key.modifier}, ${key.key}, ${key.function}, ${key.argument}}"
     ) (appKeys ++ (optionals (cfg.keys.useDefault) defaultKeys) ++ cfg.keys.bindings)
   },
   ${
     # create tag keys bindings
     concatMapStringsSep "\n" (tag: "TAGKEYS(${tag.key}, ${toString tag.tag})") cfg.tagKeys.definitions
   }
  };
  Button buttons[] = {
          ${
            concatMapStringsSep "," (
              button:
              "{${button.clickArea},${button.modifier},${button.button},${button.function},${button.argument}}"
            ) cfg.buttons
          },
      };

      ${cfg.file.append}
''
