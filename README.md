# suckless-nixos-modules
My nixos modules for suckless software.

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
