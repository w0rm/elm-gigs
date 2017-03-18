module Message exposing (Msg(..))

import Http
import Video exposing (Video)
import Clip exposing (Word)
import Window exposing (Size)


type Msg
    = VideosLoad (Result Http.Error (List Video))
    | ClipLoad (Maybe Video)
    | Measured Word
    | PlayError
    | PlayEnd
    | WindowSize Size
