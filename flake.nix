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
                  hash = "sha256-vyK+HfV7q/ZXnM+Cm/gt1UCgs4fFeq+1oH2/zSlC6PE=";
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
          rev = "v0.5.3";
          hash = "sha256-uyFI9Xyg5ftsI7f3pavI/sifVzGKlHL8ABoiyfe5yBU=";
          fetchSubmodules = true;
        };
        # Upstream FetchContent's NFD on Linux (GTK backend). Pre-fetch it so the
        # build stays offline; wired up via FETCHCONTENT_SOURCE_DIR_*.
        nfd-src = pkgs.fetchFromGitHub {
          owner = "btzy";
          repo = "nativefiledialog-extended";
          tag = "v1.3.0";
          hash = "sha256-JrwJP7zt/4oW4OQHCEM23k+zm6j1AVglGJowwkWc29k=";
        };
      in rec {
        packages = rec {
          default = lichtfeld;
          rmlui = pkgs.callPackage ./rmlui.nix {};
          imgui-sdl3 = pkgs.callPackage ./imgui-sdl3.nix {};
          nvjpeg2k-archive = pkgs.callPackage ./nvjpeg2k.nix {};
          lichtfeld = pkgs.callPackage ./lichtfeld.nix {
            inherit src nfd-src rmlui imgui-sdl3 nvjpeg2k-archive;
            imgui = pkgs.imgui;
            implot = pkgs.implot;
          };
        };
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              packages.lichtfeld
              pkgs.colmapWithCuda
              (pkgs.python313.withPackages (ps: with ps; [uv]))
            ];
          };
        };
      }
    );
}
