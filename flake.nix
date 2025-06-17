{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = {
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);
    systemPkgs = system: nixpkgs.legacyPackages.${system};
  in {
    devShells = eachSystem (system: let
      pkgs = systemPkgs system;
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # put necessary packages here...
        ];
      };
    });

    modules = import ./modules;

    packages = eachSystem (system: let
      pkgs = systemPkgs system;
    in {
      default = let
        version = "";
      in
        pkgs.stdenv.mkDerivation {
          inherit version;

          name = "";
          src = pkgs.fetchFromGitHub {
            inherit version;

            owner = "";
            repo = "";
            rev = "";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        };
    });
  };
}
