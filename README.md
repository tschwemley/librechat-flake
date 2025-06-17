# LibreChat NixOS Flake

This repository provides a Nix flake for deploying [LibreChat](https://www.librechat.ai/) and its RAG API on NixOS.

It provides NixOS modules to configure and run `librechat` and `rag_api` as systemd services.

## Usage

### Add Flake Input

In your NixOS configuration's `flake.nix`, add this repository as an input:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Replace with the actual URL to this flake
    librechat-flake.url = "github:your-github-username/this-repo-name";
  };

  outputs = { self, nixpkgs, librechat-flake, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        librechat-flake.nixosModules.librechat
        # The ragApi module is automatically included by the librechat module.
      ];
    };
  };
}
```

### Configuration Example

Here is an example configuration in your `configuration.nix`:

```nix
# configuration.nix
{ config, pkgs, ... }:

{
  services.librechat = {
    enable = true;
    openFirewall = true;
    port = 3080;
    user = "librechat";
    group = "librechat";

    # For a full list of options, see `modules/librechat.nix`
    env = {
      MONGO_URI = "mongodb://localhost:27017/LibreChat";
      # Add other environment variables here
    };
    
    settings = {
      # librechat.yaml settings go here
    };

    ragApi = {
      enable = true;
      openFirewall = true;
      port = 8000;

      # For a full list of options, see `modules/rag_api.nix`
      env = {
        DB_HOST = "localhost";
        # ...
      };
    };
  };

  # Example of using credentials from files
  # services.librechat.credentials = {
  #   OPENAI_API_KEY = /path/to/openai_key_file;
  # };
  # services.librechat.ragApi.credentials = {
  #   S3_ACCESS_KEY = /path/to/s3_key_file;
  # };
}
```

## Development

To enter a development shell with dependencies for this flake, run:

```sh
nix develop
```
