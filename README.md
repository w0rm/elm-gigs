# Gigs

**Note:** this demo only works in Chome and Firefox.

The idea is to present the short videoclips I took at gigs in 2014-2017.

Each video is masked by a band's name using [the MOD font](http://www.fontfabric.com/mod-font/)
from the Fontfabric type foundry.

![Screenshot](screenshot.jpg)

# Random technical facts

* The video is included using html5 video element
* Masking is implemented using
  [svg mask element](https://developer.mozilla.org/en/docs/Web/SVG/Element/mask)
* The text layout is calculated by measuring the size of words
  and breaking the lines where necessary, using ports
* And of course its being coded in [the Elm language](http://elm-lang.org/),
  just as my [current homepage](https://github.com/w0rm/elm-unsoundscapes)

# Running the demo

1. `elm make Main.elm --output elm.js`
2. Start a webserver `python -m SimpleHTTPServer`
3. Open [index.html](http://localhost:8000)
