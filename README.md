# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  imports = [
    (import (fetchTarball {
      url = "https://github.com/TawasalMessenger/aerospike-flake/archive/150b100772ede1de5e81bfe7db3d7f57986748ca.tar.gz";
      sha256 = "004crn1c9x1dxchw790ylfbvslynpsnkyzlr04slw2fhh5c03pys";
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
