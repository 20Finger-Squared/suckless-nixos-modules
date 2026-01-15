{ lib, config, ... }:
let
  cfg = config.programs.dwm.patches.keymodes.keybinds.tags;
  toStringXKey = x: if builtins.isString x then x else toString x;
in
/* c */ ''
  {${toStringXKey cfg.viewOnlyThisTag},       KEY, view,       {.ui = 1 << TAG} }, \
  {${toStringXKey cfg.toggleThisTagInView},   KEY, toggleview, {.ui = 1 << TAG} }, \
  {${toStringXKey cfg.moveWindowToThisTag},   KEY, tag,        {.ui = 1 << TAG} }, \
  {${toStringXKey cfg.toggleWindowOnThisTag}, KEY, toggletag,  {.ui = 1 << TAG} },
''
