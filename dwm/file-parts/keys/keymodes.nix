{ config, lib, ... }:
with lib;
let
  cfg = config.programs.dwm;
  patch = config.programs.dwm.patches.keymodes.commandMode;
  toStringXkey = x: if builtins.isString x then x else toString x;
in
/* c */ ''
  ${
    # create default key bindings before user defined bindings
    concatMapStringsSep ",\n        " (
      key: ''{${toStringXkey key.modifier}, ${toStringXkey key.key}, ${key.function}, ${key.argument} }''
    ) (if cfg.key.useDefault then defaultKeys ++ cfg.key.keys else cfg.key.keys)
  },
  { ${toStringXkey patch.modifier},${toStringXkey patch.key}, setkeymode,     {.ui = ModeCommand} }
''
