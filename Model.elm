module Model exposing (Model, ClipState(..), initial)

import Video exposing (Video)
import Clip exposing (Clip)
import Window exposing (Size)
import Dict exposing (Dict)


type ClipState
    = Initial
    | Slug String
    | Loaded Clip


type alias Model =
    { videos : Maybe (Dict String Video)
    , clip : ClipState
    , count : Int
    , size : Size
    }


initial : String -> Model
initial slug =
    { videos = Nothing
    , clip =
        if slug == "" then
            Initial
        else
            Slug slug
    , count = 0
    , size = Size 0 0
    }
