#!/bin/bash -e

if [ -f certstore.db ]; then
  echo "A certificate database already exists. If you wish to recreate it, delete the certstore.db file first." >&2
  exit 1
fi

apt-get update
apt-get -y install build-essential

go get -u bitbucket.org/liamstask/goose/cmd/goose

$GOPATH/bin/goose -path $GOPATH/src/github.com/cloudflare/cfssl/certdb/sqlite up
mv certstore_development.db certstore.db

cp -a /install /certs/install
mv install/config.json /certs/
