#!/bin/bash

URL=$1

if [ "$URL" == "" ]; then
  echo "No base URL has been specfied" >&2
  exit 1
fi

URL=${URL#http://}
URL=${URL%/}

sed -i "s/BASE_URL/$URL/" config.json
