#!/bin/bash
set -ev

rm -rf gh-pages || exit 0;

mkdir -p gh-pages

# compile JS using Elm
elm make Main.elm --yes --output gh-pages/index.html

# copy the json
cp -R videos.json gh-pages/

# configure domain
cd gh-pages
echo "gigs.unsoundscapes.com" >> CNAME

# init branch and commit
git init
git add .
git commit -m "Deploy to GitHub Pages"
git config --global user.email "clankga@mail.ru"
git config --global user.name "Andrey Kuzmin (via Travis CI)"
git push --force "https://${GITHUB_TOKEN}@github.com/w0rm/elm-gigs.git" master:gh-pages
