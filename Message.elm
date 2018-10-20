module Message exposing (Msg(..))

import Clip exposing (Word)
import Dict exposing (Dict)
import Http
import Video exposing (Video)


type Msg
    = VideosLoad (Result Http.Error (Dict String Video))
    | PlayRandom
    | NavigateTo String
    | LoadClip (Maybe String)
    | Measured Word
    | WindowSize Int Int
    | Noop
