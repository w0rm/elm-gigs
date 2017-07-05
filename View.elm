module View exposing (view)

import Html exposing (div, Html, node)
import Html.Attributes exposing (style, content, type_, src, attribute, property, autoplay, preload)
import Html.Events exposing (on, onClick)
import Svg exposing (svg, text_, text, mask, rect, tspan, g)
import Svg.Attributes exposing (viewBox, id, x, y, dy, dx, width, height, fill)
import Model exposing (Model, ClipState(..))
import Clip exposing (Clip, Word, maxWidth, minSpace)
import Json.Decode as Decode
import Message exposing (Msg(..))
import Window exposing (Size)
import String


toPx : number -> String
toPx px =
    toString px ++ "px"


view : Model -> Html Msg
view { clip, size, count } =
    case clip of
        Loaded clip_ ->
            renderClip count size clip_

        _ ->
            text ""


renderLine : Int -> Int -> List Word -> Html Msg
renderLine size lineNumber line =
    let
        wordsWidth =
            List.foldr (.width >> (+)) 0 line

        spaceSize =
            if lineNumber < size then
                toFloat (maxWidth - wordsWidth) / toFloat (List.length line - 1)
            else
                -- don't stretch the spaces on the last line
                minSpace
    in
        text_
            [ y (toString (0.75 * toFloat (lineNumber + 1)) ++ "em")
            , x "0"
            ]
            (List.indexedMap (renderWord spaceSize) line)


renderWord : Float -> Int -> Word -> Html Msg
renderWord spaceSize wordNumber w =
    if wordNumber == 0 then
        tspan [] [ text w.text ]
    else
        tspan [ dx (toPx spaceSize) ] [ text w.text ]


renderClip : Int -> Size -> Clip -> Html Msg
renderClip count dimensions { video, cover, lines, line, word, caption } =
    let
        size =
            min (min dimensions.width dimensions.height - 50) 800
    in
        div
            [ style
                [ ( "position", "absolute" )
                , ( "left", toPx ((dimensions.width - size) // 2) )
                , ( "top", toPx ((dimensions.height - size) // 2) )
                , ( "width", toPx size )
                , ( "height", toPx size )
                , ( "font", Clip.font )
                , ( "cursor", "pointer" )
                ]
            , onClick PlayRandom
            ]
            [ Html.video
                [ type_ "video/mp4"
                , src (video ++ "#" ++ toString count)
                , attribute "poster" cover
                , autoplay True
                , preload "none"
                , on "ended" (Decode.succeed PlayRandom)
                , on "error" (Decode.succeed PlayRandom)
                , style
                    [ ( "position", "absolute" )
                    , ( "width", "100%" )
                    , ( "height", "100%" )
                    , ( "background", "black" )
                    ]
                ]
                []
            , svg
                [ viewBox "0 0 640 640"
                , style
                    [ ( "position", "absolute" )
                    , ( "width", "101%" )
                    , ( "height", "101%" )
                    ]
                ]
                [ mask
                    [ id ("mask-" ++ toString (String.length word.text)) ]
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
                    , attribute "mask" ("url(#mask-" ++ toString (String.length word.text) ++ ")")
                    ]
                    []
                ]
            ]
