{pkgs, ...}: {
  rag_api = pkgs.callPackage ./rag_api.nix {};
}
