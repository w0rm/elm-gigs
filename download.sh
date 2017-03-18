#!/bin/bash
set -ev

URL="https://api.instagram.com/v1/users/self/media/recent/?access_token=$INSTAGRAM_TOKEN&count=30"
RESPONSE=$(curl -f -s "$URL")

if [ -z "$RESPONSE" ]; then
  echo "Got empty response from Instagram" 1>&2
  exit 1
fi

echo $RESPONSE > out.json
jq -s '.[0] + (.[1].data | map(select(contains({ tags: ["unsoundscapes"] })))) | unique_by(.id) | sort_by(.created_time | tonumber)' videos.json out.json > result.json
rm out.json videos.json
mv result.json videos.json

if [[ `git status --porcelain` ]]; then
  echo "No updates from Instagram"
  exit 0
fi

git add videos.json
git commit -m "Update videos"
git push "https://${GITHUB_TOKEN}@github.com/w0rm/elm-gigs.git" master
