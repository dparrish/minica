#!/bin/bash

cd /certs
cfssl ocspdump -db-config=/install/db.json > /tmp/ocspdump.txt
cfssl ocspserve -port=8889 -responses=/tmp/ocspdump.txt -loglevel=0
