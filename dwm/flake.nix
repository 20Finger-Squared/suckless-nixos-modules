{
  description = "A custom module created for dwm.";

  outputs = _: {
    nixosModules.default = import ./default.nix;
  };
}
