{ pkgs, client-c-src, admin-src, tools-backup-src, src, version }:

with pkgs;
let
  client = stdenv.mkDerivation rec {
    name = "aerospike-client-c";

    src = client-c-src;

    nativeBuildInputs = [ autoconf automake libtool ];
    buildInputs = [ openssl zlib lua ];

    phases = [ "unpackPhase" "preBuild" "buildPhase" "installPhase" ];

    preBuild = "export EVENT_LIB=";

    installPhase = ''
      mkdir -p $out/src
      cp -rv $src/* $out/src/
      cp -rv target $out/src/target
    '';
  };

  yappi = with python38Packages; buildPythonPackage rec {
    pname = "yappi";
    version = "1.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1gs48c5sy771lsjhca3m4j8ljc6yhk5qnim3n5idnlaxa4ql30bz";
    };

    checkInputs = [ nose ];
  };
in
{
  aerospike-admin = with python38Packages; buildPythonApplication rec {
    name = "aerospike-admin";

    src = admin-src;

    buildInputs = [ bcrypt cryptography jsonschema pexpect ply pyasn1 pyopenssl toml yappi future distro enum34 ];
    propagatedBuildInputs = buildInputs;

    doCheck = false;

    postPatch = ''
      substituteInPlace ./asadm.py --replace '#!/bin/sh' '#!${python}/bin/python'
    '';

    postFixup = ''
      cp -v $src/version.txt $out/bin/version.txt
    '';
  };

  aerospike-tools-backup = stdenv.mkDerivation rec {
    name = "aerospike-tools-backup";

    src = tools-backup-src;

    nativeBuildInputs = [ autoconf automake libtool ];
    buildInputs = [ openssl zlib zstd ];

    preBuild = "export CLIENTREPO=${client}/src";

    installPhase = ''
      mkdir -p $out/bin
      cp -rv ./bin/{asbackup,asrestore} $out/bin/
    '';
  };

  aerospike-server = stdenv.mkDerivation rec {
    inherit src version;
    pname = "aerospike-server";

    nativeBuildInputs = [ autoconf automake libtool gnumake ];
    buildInputs = [ openssl zlib lua ];

    prePatch = ''
      patchShebangs .
      substituteInPlace build/gen_version --replace '`git describe --abbrev=7`' '${version}'
      substituteInPlace build/gen_version --replace '`date`' ""
    '';

    NIX_CFLAGS_COMPILE = [
      "-Wno-error=address-of-packed-member"
    ];

    installPhase = ''
      mkdir -p $out/bin $out/share/udf/lua
      cp target/Linux-x86_64/bin/asd $out/bin/asd
    '';
  };
}
