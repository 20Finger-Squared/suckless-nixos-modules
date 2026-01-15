{ lib, config, ... }:
with lib;
let
  cfg = config.programs.dwm;
  keymodes = cfg.patches.keymodes;
  toStringXKey = x: if builtins.isString x then x else toString x;
in
# c
''
  static Key cmdkeys[] = {
    ${optionalString keymodes.keybinds.cmdkeys.useDefault /* c */ ''
      	/* modifier                    keys                     function         argument */
      	{ 0,                           XK_Escape,               clearcmd,        {0} },
      	{ ControlMask,                 XK_g,                    clearcmd,        {0} },
        { 0,                   XK_i,                    setkeymode,      {.ui = ModeInsert} },
    ''}
    ${
      # create keys based on user definintions
      if keymodes.keybinds.cmdkeys.binds == [ ] then
        ""
      else
        # create default key bindings before user defined bindings
        concatMapStringsSep ",\n" (
          key: ''{${toStringXKey key.modifier}, ${toStringXKey key.key}, ${key.function}, ${key.argument} }''
        ) (keymodes.keybinds.cmdkeys.binds)
    }
  };

  static Command commands[] = {
    ${optionalString (keymodes.keybinds.commands.binds != [ ]) (
      concatMapStringsSep "," (
        bind:
        let
          fillList = x: (x ++ (builtins.genList (y: 0) (4 - builtins.length x)));
          # pad list to four elements then turn elements into strings
          modifier = map (x: toString x) (fillList bind.modifier);
          keysyms = map (x: toString x) (fillList bind.keysyms);
        in
        ''{{ ${concatStringsSep "," modifier} },{ ${concatStringsSep "," keysyms} },${bind.function},{${bind.argument}}}''
      ) (keymodes.keybinds.commands.binds)
    )}
    ${optionalString keymodes.keybinds.commands.useDefault # c
      ''
        	/* modifier (4 keys)         keysyms (4 keys)         function        argument */
        	{ {0,           0, 0, 0},    { XK_p,      0, 0, 0},   spawn,          {.v = dmenucmd } },
        	{ {ShiftMask,   0, 0, 0},    { XK_Return, 0, 0, 0},   spawn,          {.v = termcmd } },
        	{ {0,           0, 0, 0},    { XK_b,      0, 0, 0},   togglebar,      {0} },
        	{ {0,           0, 0, 0},    { XK_j,      0, 0, 0},   focusstack,     {.i = +1 } },
        	{ {0,           0, 0, 0},    { XK_k,      0, 0, 0},   focusstack,     {.i = -1 } },
        	{ {ShiftMask,   0, 0, 0},    { XK_i,      0, 0, 0},   incnmaster,     {.i = +1 } },
        	{ {0,           0, 0, 0},    { XK_d,      0, 0, 0},   incnmaster,     {.i = -1 } },
        	{ {0,           0, 0, 0},    { XK_h,      0, 0, 0},   setmfact,       {.f = -0.05} },
        	{ {0,           0, 0, 0},    { XK_l,      0, 0, 0},   setmfact,       {.f = +0.05} },
        	{ {0,           0, 0, 0},    { XK_Return, 0, 0, 0},   zoom,           {0} },
        	{ {ControlMask, 0, 0, 0},    { XK_i,      0, 0, 0},   view,           {0} },
        	{ {ShiftMask,   0, 0, 0},    { XK_k,      0, 0, 0},   killclient,     {0} },
        	{ {0,           0, 0, 0},    { XK_t,      0, 0, 0},   setlayout,      {.v = &layouts[0]} },
        	{ {0,           0, 0, 0},    { XK_f,      0, 0, 0},   setlayout,      {.v = &layouts[1]} },
        	{ {0,           0, 0, 0},    { XK_m,      0, 0, 0},   setlayout,      {.v = &layouts[2]} },
        	{ {0,           0, 0, 0},    { XK_space,  0, 0, 0},   setlayout,      {0} },
        	{ {ShiftMask,   0, 0, 0},    { XK_space,  0, 0, 0},   togglefloating, {0} },
        	{ {0,           0, 0, 0},    { XK_0,      0, 0, 0},   view,           {.ui = ~0 } },
        	{ {ShiftMask,   0, 0, 0},    { XK_0,      0, 0, 0},   tag,            {.ui = ~0 } },
        	{ {0,           0, 0, 0},    { XK_comma,  0, 0, 0},   focusmon,       {.i = -1 } },
        	{ {0,           0, 0, 0},    { XK_period, 0, 0, 0},   focusmon,       {.i = +1 } },
        	{ {ShiftMask,   0, 0, 0},    { XK_comma,  0, 0, 0},   tagmon,         {.i = -1 } },
        	{ {ShiftMask,   0, 0, 0},    { XK_period, 0, 0, 0},   tagmon,         {.i = +1 } },
        	TAGKEYS(XK_1, 0)
        	TAGKEYS(XK_2, 1)
        	TAGKEYS(XK_3, 2)
        	TAGKEYS(XK_4, 3)
        	TAGKEYS(XK_5, 4)
        	TAGKEYS(XK_6, 5)
        	TAGKEYS(XK_7, 6)
        	TAGKEYS(XK_8, 7)
        	TAGKEYS(XK_9, 8)
        	{ {ShiftMask,   0, 0, 0},    { XK_q,      0, 0, 0},   quit,           {0} },''
    }
  };
''
