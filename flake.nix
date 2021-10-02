{
  description = "Aerospike NoSQL Database flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/staging-21.05";
    client-c-src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-client-c";
      submodules = true;
      ref = "refs/tags/5.2.4";
      flake = false;
    };
    admin-src = {
      url = "github:aerospike/aerospike-admin/2.4.0";
      flake = false;
    };
    tools-backup-src = {
      url = "github:aerospike/aerospike-tools-backup/3.8.0";
      flake = false;
    };
    src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-server";
      submodules = true;
      ref = "refs/tags/5.7.0.7";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, client-c-src, admin-src, tools-backup-src, src }:
    with builtins;
    let
      sources = (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      derivations = with pkgs; import ./build.nix {
        inherit pkgs client-c-src admin-src tools-backup-src src;
        version = lib.last (split "/" sources.src.original.ref);
      };
    in
    with pkgs; with derivations; rec {
      packages.${system} = derivations;
      defaultPackage.${system} = aerospike-server;
      legacyPackages.${system} = extend overlay;
      devShell.${system} = callPackage ./shell.nix derivations;
      nixosModule = {
        imports = [ ./configuration.nix ];
        nixpkgs.overlays = [ overlay ];
        services.aerospike.package = lib.mkDefault aerospike-server;
      };
      overlay = final: prev: derivations;
    };
}
