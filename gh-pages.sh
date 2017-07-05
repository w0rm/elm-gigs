#!/bin/bash
set -e

rm -rf gh-pages || exit 0;

mkdir -p gh-pages

# compile and copy assets
elm make Main.elm --yes --output gh-pages/elm.js
sed 's/\/_compile\/Main\.elm/elm\.js/g' index.html > gh-pages/index.html
cp videos.json gh-pages/

# configure domain
cd gh-pages
echo "gigs.unsoundscapes.com" >> CNAME

# init branch and commit
git init
git config user.name "Andrey Kuzmin (via Travis CI)"
git config user.email "clankga@mail.ru"
git add .
git commit -m "Deploy to GitHub Pages [skip ci]"
git push --force "https://${GITHUB_TOKEN}@github.com/w0rm/elm-gigs.git" master:gh-pages
