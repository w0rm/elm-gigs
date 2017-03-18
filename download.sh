#!/bin/sh
set -e

URL="https://api.instagram.com/v1/users/self/media/recent/?access_token=$ACCESS_TOKEN&count=30"
RESPONSE=$(curl -s "$URL")

if [ -z "$RESPONSE" ]; then
  echo "Got empty response from Instagram" 1>&2
  exit 1
fi

echo $RESPONSE > out.json
jq -s '.[0] + (.[1].data | map(select(contains({ tags: ["unsoundscapes"] })))) | unique_by(.id) | sort_by(.created_time | tonumber)' videos.json out.json > result.json
rm out.json videos.json
mv result.json videos.json
