module Clip exposing (Clip, Word, font, initial, lineWidth, maxWidth, minSpace, update)

import String
import Video exposing (Video)


font : String
font =
    "106px Mod"


maxWidth : Int
maxWidth =
    640


maxLines : Int
maxLines =
    8


minSpace : Int
minSpace =
    30


showProgress : Bool
showProgress =
    False


type alias Word =
    { text : String
    , width : Int
    }


type alias Clip =
    { video : String
    , title : String
    , cover : String
    , caption : String
    , word : Word
    , line : List Word
    , lines : List (List Word)
    }


initial : Video -> ( Clip, Maybe String )
initial { createdTime, title } =
    start
        { video = "http://gigs.unsoundscapes.com/videos/" ++ String.fromInt createdTime ++ ".mp4"
        , cover = "http://gigs.unsoundscapes.com/videos/" ++ String.fromInt createdTime ++ ".jpg"
        , caption = title ++ " "
        , title = title
        , word = Word "" 0
        , line = []
        , lines = []
        }


lineWidth : List Word -> Int
lineWidth line =
    let
        len =
            List.length line - 1
    in
    line
        |> List.map .width
        |> List.sum
        |> (+)
            (if len > 0 then
                len * minSpace

             else
                0
            )


start : Clip -> ( Clip, Maybe String )
start clip =
    case String.uncons clip.caption of
        Just ( char, rest ) ->
            ( { clip
                | caption = rest ++ String.fromChar char
              }
            , Just (String.fromChar char)
            )

        Nothing ->
            ( clip, Nothing )


addWord : Word -> List Word -> List Word
addWord word line =
    if word.text == "" then
        line

    else
        line ++ [ word ]


update : Word -> Clip -> ( Clip, Maybe String )
update ({ text, width } as newWord) clip =
    if List.length clip.lines == maxLines then
        ( clip, Nothing )

    else if lineWidth (addWord newWord clip.line) >= maxWidth then
        ( { clip
            | lines = clip.lines ++ [ addWord clip.word clip.line ]
            , line =
                []

            -- start new line
            , word =
                Word "" 0

            -- start new word
          }
        , Just (String.dropLeft (String.length text - 1) text)
        )

    else
        case String.uncons clip.caption of
            Just ( ' ', rest ) ->
                -- got a space, end of word
                update (Word "" 0)
                    { clip
                        | line =
                            addWord newWord clip.line

                        -- add new word
                        , caption = rest ++ " "
                        , word =
                            Word "" 0

                        -- start new word
                    }

            Just ( char, rest ) ->
                ( { clip
                    | word = newWord
                    , caption = rest ++ String.fromChar char
                  }
                , Just (text ++ String.fromChar char)
                )

            Nothing ->
                ( clip, Nothing )
