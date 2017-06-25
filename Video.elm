module Video exposing (Video, videos, random)

import Json.Decode as Decode exposing (Decoder)
import Random exposing (Generator)
import String
import Char
import Dict exposing (Dict)


type alias Video =
    { id : String
    , video : String
    , cover : String
    , caption : String
    }


videos : Decoder (Dict String Video)
videos =
    Decode.maybe video
        |> Decode.list
        |> Decode.map (List.foldl addVideo Dict.empty)


addVideo : Maybe Video -> Dict String Video -> Dict String Video
addVideo maybeVideo videos =
    case maybeVideo of
        Just video ->
            let
                slug =
                    findSlug videos (captionToSlug video.caption) 0
            in
                Dict.insert slug video videos

        Nothing ->
            videos


findSlug : Dict String a -> String -> Int -> String
findSlug dict str n =
    let
        key =
            if n == 0 then
                str
            else
                str ++ "-" ++ toString n
    in
        if Dict.member key dict then
            findSlug dict str (n + 1)
        else
            key


video : Decoder Video
video =
    Decode.map4
        Video
        (Decode.field "id" Decode.string)
        (Decode.at [ "videos", "standard_resolution", "url" ] Decode.string)
        (Decode.at [ "images", "standard_resolution", "url" ] Decode.string)
        (Decode.at [ "caption", "text" ] Decode.string |> Decode.andThen caption)


caption : String -> Decoder String
caption =
    String.split "#"
        >> List.head
        >> Maybe.andThen (String.split "-" >> List.head)
        >> Maybe.andThen
            (\result ->
                case String.trim result of
                    "" ->
                        Nothing

                    value ->
                        value
                            |> String.foldr replaceChars ""
                            |> Decode.succeed
                            |> Just
            )
        >> Maybe.withDefault (Decode.fail "No caption")


captionToSlug : String -> String
captionToSlug =
    String.toLower
        >> String.filter (\c -> Char.isLower c || Char.isDigit c || c == ' ')
        >> String.words
        >> String.join "-"


{-| Remove some umlauts
-}
replaceChars : Char -> String -> String
replaceChars char =
    case char of
        'ç' ->
            String.cons 'c'

        'ü' ->
            (++) "ue"

        _ ->
            String.cons char


random : Dict String Video -> Generator String
random dict =
    Random.int 0 (List.length (Dict.keys dict) - 1)
        |> Random.map ((flip List.drop) (Dict.keys dict) >> List.head >> Maybe.withDefault "")
