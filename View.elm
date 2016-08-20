module View exposing (view)

import Html exposing (div, Html, node)
import Html.Attributes exposing (style, content, type', src, attribute, property, autoplay)
import Html.Events exposing (on)
import Svg exposing (svg, text', text, mask, rect, tspan, g)
import Svg.Attributes exposing (viewBox, id, x, y, dy, dx, width, height, fill)
import Model exposing (Model)
import Clip exposing (Clip, Word, maxWidth)
import Json.Decode as Decode
import Message exposing (Msg(..))
import Window exposing (Size)
import Json.Encode exposing (bool)


(:::) : a -> b -> (a, b)
(:::) = (,)


view : Model -> Html Msg
view {clip, size, count} =
  div
    []
    [ fontFace
    , case clip of
        Just clip' -> renderClip count size clip'
        Nothing -> text ""
    ]


renderLine : Int -> List Word -> Html Msg
renderLine n line =
  let
    wordsWidth = List.map .width line |> List.sum
    spaceSize = toFloat (maxWidth - wordsWidth) / toFloat (List.length line - 1)
  in
    text'
      [ y ((0.75 * toFloat (n + 1) |> toString) ++ "em")
      , x "0"
      ]
      (List.indexedMap (renderWord spaceSize) line)


renderWord : Float -> Int -> Word -> Html Msg
renderWord spaceSize n w =
  if n == 0 then
    tspan [] [text w.text]
  else
    tspan [dx (toString spaceSize ++ "px")] [text w.text]


renderClip : Int -> Size -> Clip -> Html Msg
renderClip count dimensions {video, cover, lines} =
  let
    size = min dimensions.width dimensions.height - 50
    left = (dimensions.width - size) // 2
    top = (dimensions.height - size) // 2
  in
    div
      [ style
          [ "position" ::: "absolute"
          , "left" ::: (toString left ++ "px")
          , "top" ::: (toString top ++ "px")
          , "width" ::: (toString size ++ "px")
          , "height" ::: (toString size ++ "px")
          , "font-size" ::: "106px"
          , "font-family" ::: "Mod"
          ]
      ]
      [ Html.video
          [ type' "video/mp4"
          , src (video ++ "?" ++ toString count)
          , attribute "cover" cover
          , autoplay True
          , property "muted" (bool False)
          , on "ended" (Decode.succeed PlayEnd)
          , style
              [ "position" ::: "absolute"
              , "width" ::: "100%"
              , "height" ::: "100%"
              , "background" ::: "black"
              ]
          ]
          []
      , svg
          [ viewBox "0 0 640 640"
          , style
              [ "position" ::: "absolute"
              , "width" ::: "101%"
              , "height" ::: "101%"
              ]
          ]
          [ mask
              [ id "mask" ]
              [ rect
                  [ x "0"
                  , y "0"
                  , width "100%"
                  , height "100%"
                  , fill "#fff"
                  ]
                  []
              , g [] (List.indexedMap renderLine lines)
              ]
          , rect
              [ x "0"
              , y "0"
              , width "100%"
              , height "100%"
              , fill "#fff"
              , attribute "mask" "url(#mask)"
              ]
              []
          ]
      ]


fontFace : Html Msg
fontFace =
  node "style"
    []
    [ text
        """
        @font-face {
          font-family: Mod;
          src: url(data:application/font-woff;charset=utf-8;base64,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) format('woff');
          font-weight: normal;
          font-style: normal;
        }
        """
    ]
