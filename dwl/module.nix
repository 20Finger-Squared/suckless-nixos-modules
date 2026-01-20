{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.dwl;
  file = pkgs.writeText "config.c" (
    (import ./file.nix) {
      inherit config;
      inherit lib;
    }
  );

  keybind = types.submodule {
    options = mkOption {
      modifer = mkOption { type = types.str; };
      key = mkOption { type = types.str; };
      cmd = mkOption { type = types.str; };
      arg = mkOption { type = types.str; };
    };
  };
in
{
  options.programs.dwl = {
    enable = mkEnableOption "dwl";
    apps = {
      menucmd = mkOption {
        type = types.str;
        default = "wmenu-run";
      };
      termcmd = mkOption {
        type = types.str;
        default = "foot";
      };
    };
    modifier = mkOption {
      type = types.str;
      default = "WLR_MODIFIER_ALT";
      description = ''If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO'';
    };
    button = mkOption {
      default = [
        {
          modifer = "MODKEY";
          mouse-button = "BTN_LEFT";
          function = "moveresize    ";
          arg = "{.ui = CurMove}";
        }
        {
          modifer = "MODKEY";
          mouse-button = "BTN_MIDDLE";
          function = "togglefloating";
          arg = "{0}";
        }
        {
          modifer = "MODKEY";
          mouse-button = "BTN_RIGHT";
          function = "moveresize    ";
          arg = "{.ui = CurResize}";
        }
      ];
      type = types.listOf (
        types.submodule {
          options = {
            modifer = mkOption { type = types.str; };
            mouse-button = mkOption { type = types.str; };
            function = mkOption { type = types.str; };
            arg = mkOption { type = types.str; };
          };
        }
      );
    };
    appearance = {
      sloppyfocus = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''focus follows mouse'';
      };
      bypass_surface_visibility = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''true means idle inhibitors will disable idle tracking even if it's surface isn't visible'';
      };
      borderpx = mkOption {
        type = types.int;
        default = 1;
        example = 3;
        description = ''border pixel of windows'';
      };
      colors =
        genAttrs
          [
            "rootcolor"
            "bordercolor"
            "focuscolor"
            "urgentcolor"
          ]
          (color: {
            type = types.str;
          });
    };
    tags = {
      keys = mkOption {
        type = types.listOf (keybind);
        default = [
          {
            modifier = "MODKEY";
            key = "KEY";
            cmd = "view";
            arg = "{ui = 1 << TAG}";
          }
          {
            modifier = "MODKEY|WLR_MODIFIER_CTRL";
            key = "KEY";
            cmd = "toggleview";
            arg = "{ui = 1 << TAG}";
          }
          {
            modifier = "MODKEY|WLR_MODIFIER_SHIFT";
            key = "SKEY";
            cmd = "tag";
            arg = "{ui = 1 << TAG}";
          }
          {
            modifier = "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT";
            key = "SKEY";
            cmd = "toggletag";
            arg = "{ui = 1 << TAG}";
          }
        ];
      };
      count = mkOption {
        type = types.int;
        default = 9;
        example = 4;
        description = "tagging - TAGCOUNT must be no greater than 31";
      };
    };
    layout = mkOption {
      type = types.listOf (
        types.submodule {
          options = mkOption {
            symbol = mkOption { symbol = types.str; };
            arrangeFunction = mkOption { type = types.nullOr types.str; };
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
          arrangeFunction = null;
        }
        {
          symbol = "[M]";
          arrangeFunction = "monocle";
        }
      ];
    };
    rules = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            app_id = mkOption { type = types.str; };
            title = mkOption { type = types.nullOr types.str; };
            tags_mask = mkOption { type = types.str; };
            isfloating = mkOption { type = types.bool; };
            monitor = mkOption { type = types.int; };
          };
        }
      );
      description = ''default/example rule: can be changed but cannot be eliminated; at least one rule must exist'';

      default = [
        {
          app_id = "Gimp_EXAMPLE";
          title = null;
          tags_mask = "0";
          isfloating = true;
          monitor = -1;
        }
        {
          app_id = "firefox_EXAMPLE";
          title = null;
          tags_mask = "1 << 8";
          isfloating = false;
          monitor = -1;
        }
      ];
    };
    monRules = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.nullOr types.str; };
            mfact = mkOption { type = types.float; };
            nmaster = mkOption { type = types.int; };
            scale = mkOption { type = types.int; };
            layout = mkOption { type = types.str; };
            rotate = mkOption { type = types.str; };
            x = mkOption { type = types.int; };
            y = mkOption { type = types.int; };
          };
        }
      );
      default = [
        {
          name = null;
          mfact = 0.55;
          nmaster = 1;
          scale = 1;
          layout = "&layouts[0]";
          rotate = "WL_OUTPUT_TRANSFORM_NORMAL";
          x = -1;
          y = -1;
        }
      ];
      description = ''default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist'';
    };
    trackpad = {
      inputs = {
        scroll = mkOption {
          type = types.str;
          default = "LIBINPUT_CONFIG_SCROLL_2FG";
          description = ''
            You can choose between:
            LIBINPUT_CONFIG_SCROLL_NO_SCROLL
            LIBINPUT_CONFIG_SCROLL_2FG
            LIBINPUT_CONFIG_SCROLL_EDGE
            LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN'';
        };
        click = mkOption {
          type = types.str;
          default = "LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS";
          description = ''
            You can choose between:
            LIBINPUT_CONFIG_CLICK_METHOD_NONE
            LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
            LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER '';
        };
        button_map = mkOption {
          type = types.str;
          default = "LIBINPUT_CONFIG_TAP_MAP_LRM";
          description = ''
            You can choose between:
            LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
            LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
          '';
        };
        accel = {
          speed = mkOption {
            type = types.float;
            default = 0.0;
          };
          profile = mkOption {
            type = types.str;
            default = "LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE";
            description = ''
              You can choose between:
               LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
               LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
            '';
          };
        };
        send_events_mode = mkOption {
          type = types.str;
          default = "LIBINPUT_CONFIG_SEND_EVENTS_ENABLED";
          description = ''
            You can choose between:
             LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
             LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
             LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
          '';
        };
      };
      tap_to_click = mkOption {
        type = types.bool;
        default = true;
      };
      tap_and_drag = mkOption {
        type = types.bool;
        default = true;
      };
      drag_lock = mkOption {
        type = types.bool;
        default = true;
      };
      natural_scrolling = mkOption {
        type = types.bool;
        default = false;
      };
      disable_while_typing = mkOption {
        type = types.bool;
        default = true;
      };
      left_handed = mkOption {
        type = types.bool;
        default = false;
      };
      middle_button_emulation = mkOption {
        type = types.bool;
        default = false;
      };
    };
    keyboard = {
      settings = mkOption {
        default = [
          {
            options = ".options";
            value = null;
          }
        ];
        type = types.listOf (
          types.submodule {
            options = {
              option = mkOption { type = types.str; };
              value = mkOption { type = types.nullOr types.str; };
            };
          }
        );
      };
      repeat = {
        rate = mkOption {
          type = types.int;
          default = 25;
        };
        delay = mkOption {
          type = types.int;
          default = 600;
        };
      };
    };
    keybinds = {
      default = {
        tagKeys = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use default tag key binds";
        };
        binds = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use default dwl binds";
        };
      };
      tagBinds = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              modifier = mkOption { type = types.str; };
              key = mkOption { type = types.str; };
              tag = mkOption { type = types.int; };
            };
          }
        );
      };
      binds = mkOption {
        description = "Note that Shift changes certain key codes: 2 -> at, etc.";
        type = types.listOf keybind;
        default = [ ];
      };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        dwm = prev.dwl.overrideAttrs (oldAttrs: {
          # if package source defined use it else use normal source
          postPatch = "cp ${file} config.h; cp ${file} config.def.h";
        });
      })
    ];
    system.build.dwm-config = file;
    environment.systemPackages = [ pkgs.dwl ];
  };
}
