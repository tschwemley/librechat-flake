{pkgs, ...}: {
  rag-api = pkgs.callPackage ./rag-api.nix {};
}
