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

              imgui = prev.imgui.overrideAttrs (finalAttrs: old: {
                version = "docking";
                src = final.fetchFromGitHub {
                  owner = "ocornut";
                  repo = "imgui";
                  rev = "docking";
                  hash = "sha256-UwZ56S/pXIrix0syWEgoCL986deNoezS0OVesTJjNzI=";
                };
              });

              implot = prev.implot.overrideAttrs (finalAttrs: old: {
                version = "0.17";
                src = final.fetchFromGitHub {
                  owner = "epezent";
                  repo = "implot";
                  tag = "v${finalAttrs.version}";
                  hash = "sha256-HNzNRHPLr352EDkAci4nx5qQnPI308rGH8yHkF+n5OY=";
                };
              });
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
      in rec {
        packages = rec {
          default = lichtfeld;
          glad = pkgs.callPackage ./glad.nix {};
          rmlui = pkgs.callPackage ./rmlui.nix {};
          imgui-sdl3 = pkgs.callPackage ./imgui-sdl3.nix {};
          nvjpeg2k-archive = pkgs.callPackage ./nvjpeg2k.nix {};
          lichtfeld = pkgs.callPackage ./lichtfeld.nix {
            inherit src glad rmlui imgui-sdl3 nvjpeg2k-archive;
            imgui = pkgs.imgui;
            implot = pkgs.implot;
          };
        };
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              packages.lichtfeld
              pkgs.colmapWithCuda
            ];
          };
        };
      }
    );
}
