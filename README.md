# Gigs

**Note:** this demo only works in Chome and Firefox.

The idea is to present the short videoclips I took at gigs from my [Instagram](https://www.instagram.com/unsoundscapes/).

Each video is masked by a band's name using [the MOD font](http://www.fontfabric.com/mod-font/)
from the Fontfabric type foundry.

![Screenshot](screenshot.jpg)

# Random technical facts

* The video is included using html5 video element
* Masking is implemented using
  [svg mask element](https://developer.mozilla.org/en/docs/Web/SVG/Element/mask)
* The text layout is calculated by measuring the size of words
  and breaking the lines where necessary, using ports
* [Instagram recent media endpoint](https://www.instagram.com/developer/endpoints/users/#get_users_media_recent_self)
  is used to fetch the data, check the `download.sh` script
* And of course its being coded in [the Elm language](http://elm-lang.org/),
  just as my [current homepage](https://github.com/w0rm/elm-unsoundscapes)
* There is a Travis job that pulls new videos runs on each commit to master and once per day

# Running the demo

`elm reactor` and then open http://localhost:8000/index.html
