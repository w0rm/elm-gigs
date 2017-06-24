module Video exposing (Video, videos, random)

import Json.Decode as Decode exposing (Decoder)
import Random exposing (Generator)
import String
import Dict exposing (Dict)


type alias Video =
    { id : String
    , video : String
    , cover : String
    , caption : String
    }


videos : Decoder (Dict String Video)
videos =
    Decode.map
        (List.filterMap identity >> Dict.fromList)
        (Decode.list (Decode.maybe video))


{-| Point free or die: <https://www.youtube.com/watch?v=seVSlKazsNk>
-}
videoWithId : String -> String -> String -> String -> ( String, Video )
videoWithId id =
    ((<<) << (<<) << (<<)) ((,) id) (Video id)


video : Decoder ( String, Video )
video =
    Decode.map4
        videoWithId
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
                        Just (Decode.succeed value)
            )
        >> Maybe.withDefault (Decode.fail "No caption")


random : Dict String Video -> Generator String
random dict =
    Random.int 0 (List.length (Dict.keys dict) - 1)
        |> Random.map ((flip List.drop) (Dict.keys dict) >> List.head >> Maybe.withDefault "")
