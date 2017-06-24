module Model exposing (Model, ClipState(..), VideosState(..), initial)

import Video exposing (Video)
import Clip exposing (Clip)
import Window exposing (Size)
import Dict exposing (Dict)


type ClipState
    = Initial
    | Url String
    | Loaded Clip


type VideosState
    = NotAsked
    | Loading
    | Success (Dict String Video)


type alias Model =
    { videos : VideosState
    , clip : ClipState
    , count : Int
    , size : Size
    }


initial : Model
initial =
    Model NotAsked Initial 0 (Size 0 0)
