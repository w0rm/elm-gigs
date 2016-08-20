module Model exposing (Model, initial)

import Video exposing (Video)
import Clip exposing (Clip)
import Window exposing (Size)


type alias Model =
  { videos : List Video
  , clip : Maybe Clip
  , count : Int
  , size : Size
  }


initial : Model
initial =
  Model [] Nothing 0 (Size 0 0)
