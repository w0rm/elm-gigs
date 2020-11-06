#!/bin/bash
set -e

rm -rf gh-pages || exit 0;

mkdir -p gh-pages

# compile and copy assets
elm make Main.elm --optimize --output gh-pages/elm-temp.js
uglifyjs gh-pages/elm-temp.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=gh-pages/elm.js
rm gh-pages/elm-temp.js
cp .gitattributes gh-pages/
cp index.html gh-pages/
cp videos.json gh-pages/
cp -r videos gh-pages/

# configure domain
cd gh-pages
echo "gigs.unsoundscapes.com" >> CNAME

# init branch and commit
git init
git config user.name "Andrey Kuzmin (via Travis CI)"
git config user.email "clankga@mail.ru"
git add .
git commit -m "Deploy to GitHub Pages [skip ci]"
git push --force "git@github.com:w0rm/elm-gigs.git" master:gh-pages
