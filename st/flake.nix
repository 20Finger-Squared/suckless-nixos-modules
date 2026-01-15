{
  description = "A custom module created for st.";

  outputs = _: {
    nixosModules.default = import ./default.nix;
  };
}
