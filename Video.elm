module Video exposing (Video, videos, random)

import Json.Decode as Decode exposing (Decoder)
import Random exposing (Generator)
import String


type alias Video =
    { video : String
    , cover : String
    , caption : String
    }


videos : Decoder (List Video)
videos =
    Decode.map
        (List.filterMap identity)
        (Decode.list (Decode.maybe video))


video : Decoder Video
video =
    Decode.map3
        Video
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
                        Just (Decode.succeed value)
            )
        >> Maybe.withDefault (Decode.fail "No caption")


random : List Video -> Generator (Maybe Video)
random list =
    Random.int 0 (List.length list - 1)
        |> Random.map ((flip List.drop) list >> List.head)
