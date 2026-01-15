{ config, lib, ... }:
with lib;
let
  cfg = config.programs.dwm.patches.cool-autostart;
in
# c
''
  static const char *const autostart[] = {
    ${
      optionalString (cfg.enable && (cfg.autostart != [ ])) concatMapStringsSep ",\n" (
        value: ''"${value.cmd}", ${optionalString (value.args != null) ''"${value.args}"''} NULL''
      ) cfg.autostart
    },
  	NULL
  };
''
