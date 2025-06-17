let
  librechat = import ./librechat.nix;
  ragApi = import ./rag_api.nix;
in {
  inherit librechat ragApi;

  default = {
    imports = [
      librechat
      ragApi
    ];
  };
}
