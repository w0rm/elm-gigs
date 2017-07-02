module Gigs exposing (main)

import Navigation
import View
import Http
import Model exposing (Model, ClipState(..))
import Message exposing (..)
import Video exposing (Video)
import Task
import Clip exposing (Clip, Word)
import Random
import Window
import Navigation
import Dict exposing (Dict)


main : Program Never Model Msg
main =
    Navigation.program
        (.hash >> String.dropLeft 1 >> LoadClip)
        { init = .hash >> String.dropLeft 1 >> init
        , view = View.view
        , update = update
        , subscriptions = always (Window.resizes WindowSize)
        }


init : String -> ( Model, Cmd Msg )
init slug =
    ( Model.initial slug
    , Cmd.batch
        [ Native.Measure.measure Clip.font "trigger the font load"
            |> Task.andThen (always (Http.toTask (Http.get "/videos.json" Video.videos)))
            |> Task.attempt VideosLoad
        , Task.perform WindowSize Window.size
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideosLoad videos ->
            loadClip { model | videos = Result.toMaybe videos }

        PlayRandom ->
            navigateToRandomVideo model

        NavigateTo slug ->
            ( model, Navigation.newUrl ("#" ++ slug) )

        LoadClip slug ->
            loadClip { model | clip = Slug slug }

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

        WindowSize size ->
            ( { model | size = size }, Cmd.none )


loadClip : Model -> ( Model, Cmd Msg )
loadClip model =
    case ( model.videos, model.clip ) of
        ( Just videos, Slug slug ) ->
            initClip videos slug model

        ( Just videos, Initial ) ->
            navigateToRandomVideo model

        _ ->
            ( model, Cmd.none )


initClip : Dict String Video -> String -> Model -> ( Model, Cmd Msg )
initClip videos slug model =
    case Maybe.map Clip.initial (Dict.get slug videos) of
        Just ( clip, cmd ) ->
            ( { model | clip = Loaded clip }
            , Cmd.map Measured cmd
            )

        Nothing ->
            navigateToRandomVideo model


navigateToRandomVideo : Model -> ( Model, Cmd Msg )
navigateToRandomVideo model =
    case model.videos of
        Just videos ->
            ( { model | count = model.count + 1 }
            , Random.generate NavigateTo (Video.random videos)
            )

        Nothing ->
            ( model, Cmd.none )
