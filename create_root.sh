#!/bin/bash -e

if [ -f root.pem -o -f root-key.pem ]; then
  echo "A root certificate already exists. If you wish to recreate it, delete root.crt and root.key first." >&2
  exit 1
fi

echo "Creating Root Certificate."

cfssl gencert -initca install/ca-csr.json | cfssljson -bare root
