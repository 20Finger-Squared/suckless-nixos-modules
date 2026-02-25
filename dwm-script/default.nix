{
  pkgs,
}:
pkgs.stdenv.mkDerivation {
  name = "dwm-script";
  pname = "dwm-script";
  src = pkgs.fetchgit {
    url = "https://github.com/20Finger-Squared/dwm-script.git";
    rev = "2ee3d97";
    sha256 = "sha256-k4G7q2jzbh8duKgaOexhQHdI4prFM0uaJmgDg2KIezk";
  };

  nativeBuildInputs = [ pkgs.clang ];

  buildPhase = "$CC -O3 dwm.c -o dwm-script";
  installPhase = "mkdir -p $out/bin; install -t $out/bin dwm-script";
}
