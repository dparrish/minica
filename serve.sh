#!/bin/bash

cd /certs
cfssl serve \
  -address=0.0.0.0 \
  -db-config=/install/db.json \
  -loglevel=0 \
  -ca-key=intermediate-key.pem \
  -ca=intermediate.pem \
  -config=config.json \
  -responder=server-ocsp.pem \
  -responder-key=server-ocsp-key.pem
