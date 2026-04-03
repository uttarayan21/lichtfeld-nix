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
          overlays = [
            (final: prev: {
              python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
                openusd = pyPrev.openusd.overrideAttrs (old: rec {
                  version = "26.03";
                  src = final.fetchFromGitHub {
                    owner = "PixarAnimationStudios";
                    repo = "OpenUSD";
                    tag = "v${version}";
                    hash = "sha256-Ijh7x63TqEkittO+r//sIkBu7I52/6C7a2n9Nq6Kt7g=";
                  };
                  patches = [];
                });
              });
              openusd = final.python313Packages.openusd;
            })
          ];
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
