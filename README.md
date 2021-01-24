# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  imports = [
    (import (fetchTarball {
      url = "https://github.com/TawasalMessenger/aerospike-flake/archive/ef36ea8f31885e051885c1d3a18dacc387f30f4d.tar.gz";
      sha256 = "0s26i28zarr15ss0nqmj5050ikg5khwmyrxc08rr4r6rz9wd2ckz";
    })).nixosModule
  ];
  services.aerospike.enable = true;
# ...
}
```
