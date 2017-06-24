module Gigs exposing (main)

import Navigation
import View
import Http
import Model exposing (Model, ClipState(..), VideosState(..))
import Message exposing (..)
import Video
import Task
import Clip
import Random
import Window
import Navigation
import Dict


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideosLoad (Ok videos) ->
            ( { model | videos = Success videos }
            , case model.clip of
                Url videoId ->
                    Task.succeed videoId |> Task.perform ClipLoad

                _ ->
                    Random.generate RandomVideo (Video.random videos)
            )

        VideosLoad (Err _) ->
            ( model, Cmd.none )

        ClipLoad videoId ->
            case model.videos of
                NotAsked ->
                    ( { model
                        | clip =
                            if videoId == "" then
                                Initial
                            else
                                Url videoId
                        , videos = Loading
                      }
                    , Cmd.batch
                        [ Native.Measure.measure Clip.font "trigger the font"
                            |> Task.andThen (always (Http.toTask (Http.get "/videos.json" Video.videos)))
                            |> Task.attempt VideosLoad
                        , Task.perform WindowSize Window.size
                        ]
                    )

                Loading ->
                    ( model, Cmd.none )

                Success videos ->
                    case Dict.get videoId videos of
                        Just video ->
                            let
                                ( clip, cmd ) =
                                    Clip.initial video
                            in
                                ( { model | clip = Loaded clip }
                                , Cmd.map Measured cmd
                                )

                        Nothing ->
                            ( model, Cmd.none )

        Measured line ->
            case model.clip of
                Loaded clip ->
                    let
                        ( newClip, cmd ) =
                            Clip.update line clip
                    in
                        ( { model | clip = Loaded newClip }
                        , Cmd.map Measured cmd
                        )

                _ ->
                    ( model, Cmd.none )

        PlayRandom ->
            ( { model | count = model.count + 1 }
            , case model.videos of
                Success videos ->
                    Random.generate RandomVideo (Video.random videos)

                _ ->
                    Cmd.none
            )

        RandomVideo videoId ->
            ( model, Navigation.newUrl ("#" ++ videoId) )

        WindowSize size ->
            { model | size = size } ! []


main : Program Never Model Msg
main =
    Navigation.program
        (.hash >> String.dropLeft 1 >> ClipLoad)
        { init = .hash >> String.dropLeft 1 >> ClipLoad >> ((flip update) Model.initial)
        , view = View.view
        , update = update
        , subscriptions = always (Window.resizes WindowSize)
        }
