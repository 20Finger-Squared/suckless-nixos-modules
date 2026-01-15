{ lib, config, ... }:
with lib;
let
  cfg = config.programs.dwm;
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
  toStringXkey = x: if builtins.isString x then x else toString x;
in
#c
''
  {${toStringXkey cfg.terminal.modifier}, ${toStringXkey cfg.terminal.launchKey}, spawn, {.v=termcmd}},
  {${toStringXkey cfg.appLauncher.modifier}, ${toStringXkey cfg.appLauncher.launchKey}, spawn, {.v=dmenucmd}},
  ${
    # create default key bindings before user defined bindings
    concatMapStringsSep ",\n        " (
      key: ''{${toStringXkey key.modifier}, ${toStringXkey key.key}, ${key.function}, ${key.argument} }''
    ) (if cfg.key.useDefault then defaultKeys ++ cfg.key.keys else cfg.key.keys)
  },
  ${optionalString (cfg.patches.keymodes.enable)
    # create tag keys bindings
    (
      concatMapStringsSep "\n        " (
        tag: ''TAGKEYS(${tag.key}, ${toString tag.tag})''
      ) cfg.tagKeys.definitions
    )
  }
''
