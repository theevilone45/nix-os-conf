{
  description = "Python project development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nil
            python314
            python314Packages.pip
            python314Packages.virtualenv
            nixd
          ];

          shellHook = ''
            echo "🔧 Python development environment loaded"
            echo "  Python:   $(python --version | head -1)"
          '';
        };
      }
    );
}
