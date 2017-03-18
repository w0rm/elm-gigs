#!/bin/bash
set -e

rm -rf gh-pages || exit 0;

mkdir -p gh-pages

# compile JS using Elm
elm make Main.elm --yes --output gh-pages/$i.html

# copy the json
cp -R videos.json gh-pages/

# configure domain
cd gh-pages
echo "gigs.unsoundscapes.com" >> CNAME

# init branch and commit
git init
git add .
git commit -m "Deploying to GH Pages"
git push --force "git@github.com:w0rm/elm-gigs.git" master:gh-pages
