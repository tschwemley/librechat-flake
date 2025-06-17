{
  description = "A Nix flake for deploying LibreChat and its RAG API on NixOS";

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

    nixosModules = import ./modules;
    packages = eachSystem (system: let pkgs = systemPkgs system; in import ./packages pkgs);
  };
}
