{
  config,
  lib,
  pkgs,
  ...
}: let
  export = n: v: ''export ${n}="${builtins.toString v}"'';
  exportAll = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList export vars);
  exportCredentials = n: _: ''export ${n}="$(${pkgs.systemd}/bin/systemd-creds cat ${n}_FILE)"'';
  exportAllCredentials = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList exportCredentials vars);
  transformCredential = n: v: "${n}_FILE:${v}";

  librechatCfg = config.services.librechat;
  cfg = librechatCfg.ragApi;

  getLoadCredentialList = lib.mapAttrsToList transformCredential cfg.credentials;
  mkStrOption = attrs: lib.mkOption ({type = lib.types.str;} // attrs);

  package = pkgs.callPackage ../packages/rag-api.nix {};
in {
  options.services.librechat.ragApi = {
    enable = lib.mkEnableOption "ragApi";
    cacheDir = mkStrOption {default = "/var/cache/rag-api";};
    workDir = mkStrOption {default = "/var/lib/rag-api";};

    credentials = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      example = {
        CREDS_KEY = /run/secrets/creds_key;
      };
      description = "Environment variables which are loaded from the contents of files at a file paths, mainly used for secrets. See https://www.librechat.ai/docs/configuration/dotenv for a full list.";
    };

    env = lib.mkOption {
      type = with lib.types;
        attrsOf (oneOf [
          str
          path
          int
          float
        ]);
      example = {
        ALLOW_REGISTRATION = "true";
        HOST = "0.0.0.0";
        CONSOLE_JSON_STRING_LENGTH = 255;
      };
      default = {};
      description = "Environment variables that will be set for the service. See https://www.librechat.ai/docs/configuration/dotenv for a full list.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      example = 2310;
      description = "The value that will be passed to the PORT environment variable, telling LibreChat what to listen on.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.env ? RAG_PORT -> cfg.port == cfg.env.RAG_PORT;
        message = "`services.librechat.ragApi.port` and `services.librechat.ragApi.env.PORT` must be set to equal values.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optional librechatCfg.openFirewall cfg.port;

    systemd = {
      packages = [package];
      services.librechat-rag-api = {
        enable = true;

        before = ["librechat.service"];
        wantedBy = [
          "multi-user.target"
          "librechat.service"
        ];

        description = "Open-source app for all your AI conversations, fully customizable and compatible with any AI provider";
        serviceConfig = {
          Type = "simple";
          User = librechatCfg.user;
          Group = librechatCfg.group;
          LoadCredential = getLoadCredentialList;

          CacheDirectory = cfg.cacheDir;
          WorkingDirectory = cfg.workDir;
        };

        script =
          # sh
          ''
            cd ${cfg.workDir}

            ${exportAll cfg.env}
            ${exportAllCredentials cfg.credentials}
            ${lib.getExe package}
          '';
      };

      tmpfiles.settings = {
        "11-librechat-rag"."${cfg.workDir}".d = {
          mode = "0765";
          inherit (librechatCfg) user group;
        };

        "11-librechat-rag-uploads"."${cfg.workDir}/uploads".d = {
          mode = "0765";
          inherit (librechatCfg) user group;
        };
      };
    };
  };
}
