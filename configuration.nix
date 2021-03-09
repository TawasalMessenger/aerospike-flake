{ config, pkgs, ... }:
let
  cfg = config.services.aerospike;
  aerospikeConf = pkgs.writeText "aerospike.conf" ''
    # This stanza must come first.
    service {
      user aerospike
      group aerospike
      paxos-single-replica-limit 1 # Number of nodes where the replica count is automatically reduced to 1.
      proto-fd-max 15000
      work-directory ${cfg.workDir}
    }
    logging {
      console {
        context any info
      }
    }
    mod-lua {
      user-path ${cfg.workDir}/udf/lua
    }
    network {
      ${cfg.networkConfig}
    }
    ${cfg.extraConfig}
  '';
in
with pkgs.lib; mkIf cfg.enable {
  boot.kernel.sysctl = {
    "kernel.shmall" = mkDefault 4294967296;
    "kernel.shmmax" = mkDefault 1073741824;
    "net.core.rmem_max" = mkDefault 15728640;
    "net.core.wmem_max" = mkDefault 5242880;
  };
  systemd = {
    tmpfiles.rules = [
      "d '${cfg.workDir}' 0700 aerospike aerospike - -"
    ];
    services.aerospike = {
      serviceConfig = {
        Restart = "always";
        RestartSec = mkOverride 0 1;
        LimitNOFILE = mkDefault 1048576;

        ReadWriteDirectories = cfg.workDir;
        ExecStart = mkForce "${cfg.package}/bin/asd --foreground --config-file ${aerospikeConf}";
        preStart = mkForce "";

        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

        NoNewPrivileges = true;
        ProtectHome = "yes";
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        PrivateDevices = true;
        PrivateTmp = true;
        SystemCallArchitectures = "native";
      };
      unitConfig = {
        StartLimitIntervalSec = 3;
        StartLimitBurst = 0;
      };
    };
  };
}
