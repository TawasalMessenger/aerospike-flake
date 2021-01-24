{ mkShell, aerospike-server, aerospike-admin, aerospike-tools-backup }:

mkShell {
  name = "aerospike-env";

  buildInputs = [ aerospike-server aerospike-admin aerospike-tools-backup ];
}
