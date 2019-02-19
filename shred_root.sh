#!/bin/bash -e

if [ ! -f /certs/root-key.pem ]; then
  echo "No root certificate key exists" >&2
  exit 0
fi

echo "This will permanently destroy the Root certificate key."
echo "MAKE SURE you have backed up the files before continuing"
echo
echo "Sleeping for 10 seconds. Press Ctrl-C if you do not wish to delete the root key"
sleep 10

if [ -f /certs/root-key.pem ]; then
  shred -u /certs/root-key.pem
fi

