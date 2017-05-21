module Gigs exposing (main)

import Html exposing (program)
import View
import Http
import Model exposing (Model)
import Message exposing (..)
import Video
import Task
import Clip
import Random
import Window


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideosLoad videosResult ->
            case videosResult of
                Ok videos ->
                    { model
                        | videos = videos
                    }
                        ! [ Random.generate ClipLoad (Video.random videos) ]

                Err _ ->
                    model ! []

        ClipLoad maybeVideo ->
            case maybeVideo of
                Just video ->
                    let
                        ( clip, cmd ) =
                            Clip.initial video
                    in
                        ( { model | clip = Just clip }, Cmd.map Measured cmd )

                Nothing ->
                    model ! []

        Measured line ->
            case model.clip of
                Nothing ->
                    model ! []

                Just clip ->
                    let
                        ( newClip, cmd ) =
                            Clip.update line clip
                    in
                        ( { model | clip = Just newClip }, Cmd.map Measured cmd )

        PlayError ->
            { model | count = model.count + 1 } ! [ Random.generate ClipLoad (Video.random model.videos) ]

        PlayEnd ->
            { model | count = model.count + 1 } ! [ Random.generate ClipLoad (Video.random model.videos) ]

        WindowSize size ->
            { model | size = size } ! []


main : Program Never Model Msg
main =
    program
        { init =
            ( Model.initial
            , Cmd.batch
                [ Native.Measure.measure Clip.font "trigger the font"
                    |> Task.andThen
                        (always (Http.toTask (Http.get "/videos.json" Video.videos)))
                    |> Task.attempt VideosLoad
                , Task.perform WindowSize Window.size
                ]
            )
        , view = View.view
        , update = update
        , subscriptions = always (Window.resizes WindowSize)
        }
