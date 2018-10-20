module Model exposing (ClipState(..), Model, SoundState(..), initial)

import Browser.Navigation exposing (Key)
import Clip exposing (Clip)
import Dict exposing (Dict)
import Video exposing (Video)


type ClipState
    = Initial
    | Slug String
    | Loaded Clip


type SoundState
    = Hidden
    | Shown
    | Enabled


type alias Model =
    { videos : Maybe (Dict String Video)
    , clip : ClipState
    , count : Int
    , width : Int
    , height : Int
    , key : Key
    , sound : SoundState
    }


initial : Maybe String -> Key -> Model
initial fragment key =
    { videos = Nothing
    , clip =
        case fragment of
            Nothing ->
                Initial

            Just slug ->
                Slug slug
    , count = 0
    , width = 0
    , height = 0
    , key = key
    , sound = Shown
    }
