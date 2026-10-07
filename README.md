# suckless-nixos-modules
no longer updating this repo. feel free to take the code if you wish. 

My nixos modules for suckless and adjacent software.
And a package for the dwm-script.

# implementation
## flakes
minimal example
```nix
{
  description = "example flake.nix";

  inputs = { suckless-modules.url = "github:20Finger-Squared/suckless-nixos-modules"; }

  outputs = { self, nixpkgs, suckless-modules, ... }:
    {
        nixpkgs.lib.nixosSystem {
          modules = [
            suckless-modules.nixosModules.default
          ];
        };
    };
}
```
