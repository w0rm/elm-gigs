module Gigs exposing (main)

import Navigation
import View
import Http
import Model exposing (Model, ClipState(..), VideosState(..))
import Message exposing (..)
import Video exposing (Video)
import Task
import Clip exposing (Clip, Word)
import Random
import Window
import Navigation
import Dict exposing (Dict)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideosLoad (Ok videos) ->
            case model.clip of
                Slug slug ->
                    case Maybe.map Clip.initial (Dict.get slug videos) of
                        Just ( clip, cmd ) ->
                            ( { model
                                | videos = Success videos
                                , clip = Loaded clip
                              }
                            , Cmd.map Measured cmd
                            )

                        Nothing ->
                            ( { model | videos = Success videos }
                            , Random.generate NavigateTo (Video.random videos)
                            )

                _ ->
                    ( { model | videos = Success videos }
                    , Random.generate NavigateTo (Video.random videos)
                    )

        VideosLoad (Err _) ->
            ( model, Cmd.none )

        ClipLoad slug ->
            case model.videos of
                NotAsked ->
                    ( { model
                        | clip =
                            if slug == "" then
                                Initial
                            else
                                Slug slug
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
                    case Maybe.map Clip.initial (Dict.get slug videos) of
                        Just ( clip, cmd ) ->
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
                    Random.generate NavigateTo (Video.random videos)

                _ ->
                    Cmd.none
            )

        NavigateTo slug ->
            ( model, Navigation.newUrl ("#" ++ slug) )

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
