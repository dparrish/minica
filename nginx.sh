#!/bin/bash

mkdir -p /tmp/empty
/usr/local/bin/crl.sh
nginx -g 'daemon off;'
