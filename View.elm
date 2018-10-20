module View exposing (view)

import Browser exposing (Document)
import Clip exposing (Clip, Word, maxWidth, minSpace)
import Html exposing (Html, div, node)
import Html.Attributes exposing (attribute, autoplay, preload, property, src, style, type_)
import Html.Events exposing (on, onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import Message exposing (Msg(..))
import Model exposing (ClipState(..), Model)
import String
import Svg exposing (g, mask, rect, svg, text, text_, tspan)
import Svg.Attributes exposing (dx, dy, fill, height, id, viewBox, width, x, y)


toPx : Int -> String
toPx px =
    String.fromInt px ++ "px"


view : Model -> Document Msg
view ({ clip, width, height, count } as m) =
    case clip of
        Loaded clip_ ->
            { title = clip_.title
            , body = [ renderClip count m.width m.height clip_ ]
            }

        _ ->
            { title = "", body = [] }


renderLine : Int -> Int -> List Word -> Html Msg
renderLine size lineNumber line =
    let
        wordsWidth =
            List.foldr (.width >> (+)) 0 line

        spaceSize =
            if lineNumber < size then
                 (maxWidth - wordsWidth) // (List.length line - 1)

            else
                -- don't stretch the spaces on the last line
                minSpace
    in
    text_
        [ y (String.fromFloat (0.75 * toFloat (lineNumber + 1)) ++ "em")
        , x "0"
        ]
        (List.indexedMap (renderWord spaceSize) line)


renderWord : Int -> Int -> Word -> Html Msg
renderWord spaceSize wordNumber w =
    if wordNumber == 0 then
        tspan [] [ text w.text ]

    else
        tspan [ dx (toPx spaceSize) ] [ text w.text ]


renderClip : Int -> Int -> Int -> Clip -> Html Msg
renderClip count width_ height_ { video, cover, lines, line, word, caption } =
    let
        size =
            min (min width_ height_ - 50) 800
    in
    div
        [ style "position" "absolute"
        , style "left" (toPx ((width_ - size) // 2))
        , style "top" (toPx ((height_ - size) // 2))
        , style "width" (toPx size)
        , style "height" (toPx size)
        , style "font" Clip.font
        , style "cursor" "pointer"
        , onClick PlayRandom
        ]
        [ Html.video
            [ type_ "video/mp4"
            , src (video ++ "#" ++ String.fromInt count)
            --, attribute "poster" cover
            , autoplay True
            , property "muted" (Encode.bool True)
            , preload "none"
            , on "ended" (Decode.succeed PlayRandom)
            , on "error" (Decode.succeed PlayRandom)
            , style "position" "absolute"
            , style "width" "100%"
            , style "height" "100%"
            , style "background" "black"
            ]
            []
        , svg
            [ viewBox "0 0 640 640"
            , style "position" "absolute"
            , style "width" "101%"
            , style "height" "101%"
            ]
            [ mask
                [ id ("mask-" ++ String.fromInt (String.length word.text)) ]
                -- changing id of the mask forces redraw
                [ rect
                    [ x "0"
                    , y "0"
                    , width "100%"
                    , height "100%"
                    , fill "#fff"
                    ]
                    []
                , g []
                    (List.indexedMap
                        (renderLine (List.length lines))
                        (lines ++ [ line ++ [ word ] ])
                    )
                ]
            , rect
                [ x "0"
                , y "0"
                , width "100%"
                , height "100%"
                , fill "#fff"
                , attribute "mask" ("url(#mask-" ++ String.fromInt (String.length word.text) ++ ")")
                ]
                []
            ]
        ]
