{
  description = "Aerospike NoSQL Database flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:TimothyKlim/flake-compat/0eb07ce2c5fc1a104d77dcc073806b39f7defc78";
      flake = false;
    };
    client-c-src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-client-c";
      ref = "refs/tags/5.1.0";
      submodules = true;
      flake = false;
    };
    admin-src = {
      url = "github:aerospike/aerospike-admin/2.1.1";
      flake = false;
    };
    tools-backup-src = {
      url = "github:aerospike/aerospike-tools-backup/3.5.0";
      flake = false;
    };
    src = {
      type = "git";
      url = "https://github.com/aerospike/aerospike-server";
      ref = "refs/tags/5.5.0.3";
      submodules = true;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat, client-c-src, admin-src, tools-backup-src, src }:
    with builtins;
    let
      sources = (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      derivations = with pkgs; import ./build.nix {
        inherit pkgs client-c-src admin-src tools-backup-src src;
        version = lib.last (split "/" sources.src.original.ref);
      };
      mkApp = drv: {
        type = "app";
        program = "${drv.pname or drv.name}${drv.passthru.exePath}";
      };
    in
    with pkgs; with derivations; rec {
      packages.${system} = derivations;
      defaultPackage.${system} = aerospike-server;
      apps.${system} = {
        aerospike-server = mkApp { drv = aerospike-server; };
        aerospike-admin = mkApp { drv = aerospike-admin; };
        aerospike-tools-backup = mkApp { drv = aerospike-tools-backup; };
      };
      defaultApp.${system} = apps.aerospike-server;
      legacyPackages.${system} = extend overlay;
      devShell.${system} = callPackage ./shell.nix derivations;
      nixosModule = {
        imports = [
          ./configuration.nix
        ];
        nixpkgs.overlays = [ overlay ];
        services.aerospike.package = lib.mkDefault aerospike-server;
      };
      overlay = final: prev: derivations;
    };
}
