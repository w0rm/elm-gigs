module Clip exposing (Clip, Word, initial, update, lineWidth, maxWidth, minSpace, font)

import Video exposing (Video)
import String
import Native.Measure
import Task
import Process


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
    , cover : String
    , caption : String
    , word : Word
    , line : List Word
    , lines : List (List Word)
    }


initial : Video -> ( Clip, Cmd Word )
initial { video, cover, caption } =
    start
        { video = video
        , cover = cover
        , caption = caption ++ " "
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


start : Clip -> ( Clip, Cmd Word )
start clip =
    case String.uncons clip.caption of
        Just ( char, rest ) ->
            ( { clip
                | caption = rest ++ String.fromChar char
              }
            , measureText (String.fromChar char)
            )

        Nothing ->
            ( clip, Cmd.none )


addWord : Word -> List Word -> List Word
addWord word line =
    if word.text == "" then
        line
    else
        line ++ [ word ]


update : Word -> Clip -> ( Clip, Cmd Word )
update ({ text, width } as newWord) clip =
    if List.length clip.lines == maxLines then
        clip ! []
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
        , measureText (String.dropLeft (String.length text - 1) text)
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
                , measureText (text ++ String.fromChar char)
                )

            Nothing ->
                clip ! []


measureText : String -> Cmd Word
measureText text =
    Task.perform
        (.width >> Word text)
        (text
            |> Native.Measure.measure font
            |> (if showProgress then
                    Task.andThen
                        (\val ->
                            Task.andThen (\_ -> Task.succeed val) (Process.sleep 50)
                        )
                else
                    identity
               )
        )
