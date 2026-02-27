{ pkgs, ... }:
{
  imports = [
    ./dmenu/module.nix
    ./dwm
    ./st
  ];
  nixpkgs.overlays = [
    (final: prev: {
      dwm-script = prev.callPackage ./dwm-script { };
    })
  ];
}
