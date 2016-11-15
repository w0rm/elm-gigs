module Video exposing (Video, load, random)

import Json.Decode as Decode exposing (Decoder)
import Random exposing (Generator)
import Http
import String


type alias Video =
    { video : String
    , cover : String
    , caption : String
    }


videos : String -> Decoder (List Video)
videos tagName =
    Decode.map
        (List.filterMap identity)
        (Decode.list (Decode.maybe (video tagName)))
        |> Decode.andThen
            (\videos ->
                case videos of
                    [] ->
                        Decode.fail "No videos"

                    videos ->
                        Decode.succeed videos
            )


video : String -> Decoder Video
video tagName =
    Decode.field "tags" (Decode.list Decode.string)
        |> Decode.andThen
            (\tags ->
                if List.member tagName tags then
                    Decode.map3
                        Video
                        (Decode.at [ "videos", "standard_resolution", "url" ] Decode.string)
                        (Decode.at [ "images", "standard_resolution", "url" ] Decode.string)
                        (Decode.at [ "caption", "text" ] Decode.string |> Decode.andThen caption)
                else
                    Decode.fail "Wrong tags"
            )


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


load : String -> String -> Http.Request (List Video)
load tagName url =
    Http.get url (Decode.field "data" (videos tagName))


random : List Video -> Generator (Maybe Video)
random list =
    Random.int 0 (List.length list - 1)
        |> Random.map ((flip List.drop) list >> List.head)
