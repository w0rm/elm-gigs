module Message exposing (Msg(..))

import Http
import Video exposing (Video)
import Clip exposing (Word)
import Window exposing (Size)
import Dict exposing (Dict)


type Msg
    = VideosLoad (Result Http.Error (Dict String Video))
    | PlayRandom
    | NavigateTo String
    | LoadClip String
    | Measured Word
    | WindowSize Size
