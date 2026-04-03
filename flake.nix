{
  description = "Flake utils demo";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    lichtfeld = {
      url = "github:MrNeRF/LichtFeld-Studio?submodules=1";
      flake = false;
    };
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
      in {
        packages = rec {
          default = lichtfeld;
          glad = pkgs.callPackage ./glad.nix {};
          rmlui = pkgs.callPackage ./rmlui.nix {};
          lichtfeld = pkgs.callPackage ./lichtfeld.nix {
            src = inputs.lichtfeld;
            inherit glad rmlui;
          };
        };
      }
    );
}
