{ config, lib, ... }:
with lib;
let
  cfg = config.programs.dwm.patches.keymodes.keybinds.tags;
  create-bind =
    key:
    if key == [ ] then
      ""
    else
      (
        let
          fillList = x: (x ++ (builtins.genList (_: 0) (4 - builtins.length x)));
          modifier = map (x: toString x) (fillList key);
        in
        ''{ ${concatStringsSep "," modifier} }''
      );
in
# c
''
  {${create-bind cfg.viewOnlyThisTag}, {KEY, 0, 0, 0 }, view,       {.ui = 1 << TAG} }, \
  {${create-bind cfg.toggleThisTagInView}, {KEY, 0, 0, 0 }, toggleview, {.ui = 1 << TAG} }, \
  {${create-bind cfg.moveWindowToThisTag}, {KEY, 0, 0, 0 }, tag,        {.ui = 1 << TAG} }, \
  {${create-bind cfg.toggleWindowOnThisTag}, {KEY, 0, 0, 0 }, toggletag,  {.ui = 1 << TAG} },
''
