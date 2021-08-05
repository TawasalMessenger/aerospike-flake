{
  description = "Aerospike NoSQL Database flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/staging-21.05";
    client-c-src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-client-c";
      ref = "refs/tags/5.2.2";
      submodules = true;
      flake = false;
    };
    admin-src = {
      url = "github:aerospike/aerospike-admin/2.2.0";
      flake = false;
    };
    tools-backup-src = {
      url = "github:aerospike/aerospike-tools-backup/3.6.1";
      flake = false;
    };
    src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-server";
      ref = "refs/tags/5.6.0.9";
      submodules = true;
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
