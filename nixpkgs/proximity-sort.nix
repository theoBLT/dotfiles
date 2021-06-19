{ lib, pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "proximity-sort";
  version = "v1.0.7";

  src = pkgs.fetchFromGitHub {
    owner = "jonhoo";
    repo = pname;
    rev = version;
    sha256 = "0d4068pkcfmcshxwkmwzlf4jyhfpilvf93m3lc1gjr8kc7jbhcb4";
  };

  cargoSha256 = "02n6h7zwnxmlw2w534yldl9sr6adhy9g4ba15x30j7bizbm6gbl2";

  meta = with lib; {
    description = "Simple command-line utility for sorting inputs by proximity to a path argument";
    homepage = "https://github.com/jonhoo/proximity-sort";
    license = licenses.mit;
  };
}

