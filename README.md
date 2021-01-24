# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  imports = [
    (import (fetchTarball {
      url = "https://github.com/TawasalMessenger/aerospike-flake/archive/5.4.0.2.tar.gz";
      sha256 = "0lgddk97qcp5883br2dinyi3i7d4frk0xc7q1q2rn5fxbbbk55fm";
    })).nixosModule
  ];
  services.aerospike.enable = true;

  # Only this version supports `submodules` attribute for fetchTree
  nix.package = with pkgs; nixUnstable.overrideAttrs (_: {
    name = "nix-2.4";
    suffix = "";
    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nix";
      rev = "b7bfc7ee52dd425e0156f369eb4c05a62358f912";
      sha256 = "WCUtN3ICisLlSRDk4Tgl9Gh7+74TuNGsAXwKHpm3uVg=";
    };
    patches = [ ];
  });
# ...
}
```
