{ pkgs, ... }:
{
  imports = [
    ./dmenu/module.nix
    ./dwm
    ./st/module.nix
  ];
  nixpkgs.overlays = [
    (final: prev: {
      dwm-script = prev.callPackage ./dwm-script { };
    })
  ];
}
