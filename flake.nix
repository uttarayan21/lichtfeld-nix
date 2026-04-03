{
  description = "Flake utils demo";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        src = pkgs.fetchFromGitHub {
          owner = "MrNeRF";
          repo = "LichtFeld-Studio";
          rev = "v0.5.1";
          hash = "sha256-9cKzLRucYc60u0VtE+0hdiiiYTbqCh0UcsHTNnyYpXc=";
          fetchSubmodules = true;
        };
      in {
        packages = rec {
          default = lichtfeld;
          glad = pkgs.callPackage ./glad.nix {};
          rmlui = pkgs.callPackage ./rmlui.nix {};
          lichtfeld = pkgs.callPackage ./lichtfeld.nix {
            inherit src glad rmlui;
          };
        };
      }
    );
}
