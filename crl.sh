#!/bin/bash

cd /certs
mkdir -p /tmp/crl
cfssl crl -db-config=/install/db.json -ca=intermediate.pem -ca-key=intermediate-key.pem | base64 --decode > /tmp/crl/crl
