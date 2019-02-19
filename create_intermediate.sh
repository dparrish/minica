#!/bin/bash -e

if [ -f intermediate.pem -o -f intermediate-key.pem ]; then
  echo "A intermediate certificate already exists. If you wish to recreate it, delete intermediate.pem and intermediate-key.pem first." >&2
  exit 1
fi

if [ ! -f root.pem -o ! -f root-key.pem ]; then
  echo "No root certificate keypair was found. Restore root.pem and root-key.pem from offline storage to generate an Intermediate key." >&2
  exit 1
fi

# Create intermediate cert
cfssl gencert -ca=root.pem -ca-key=root-key.pem -config=config.json -profile=intermediate install/intermediate-csr.json | cfssljson -bare intermediate -

# Create OCSP signing cert, signed by the intermediate.
cfssl gencert -ca=intermediate.pem -ca-key=intermediate-key.pem -config=config.json -profile=ocsp install/ocsp-csr.json | cfssljson -bare server-ocsp - 

cat /certs/root.pem /certs/intermediate.pem > /certs/bundle.pem
