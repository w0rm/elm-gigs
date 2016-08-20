#!/bin/sh

url="https://api.instagram.com/v1/users/self/media/recent/?access_token=$ACCESS_TOKEN&count=50"

echo '{"data":[]}' > data.json

while [[ $url != null ]]; do
  response=$(curl -s "$url")
  echo $response > out.json
  url=$(jq --raw-output '.pagination.next_url' out.json)
  jq -s '.[0].data + .[1].data | map(select(contains({tags: ["unsoundscapes"]}))) | {data: .}' data.json out.json > result.json
  rm out.json data.json
  mv result.json data.json
  sleep 2
done
