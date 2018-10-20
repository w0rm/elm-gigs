port module Gigs exposing (main)

import Browser
import Browser.Dom exposing (getViewport)
import Browser.Events exposing (onResize)
import Browser.Navigation as Navigation exposing (Key)
import Clip exposing (Clip, Word)
import Dict exposing (Dict)
import Http
import Message exposing (..)
import Model exposing (ClipState(..), Model, SoundState(..))
import Random
import Task
import Url exposing (Url)
import Video exposing (Video)
import View


{-| port for sending text to measure out to JavaScript
-}
port measure : { font : String, text : String } -> Cmd msg


{-| port for listening for measurements from JavaScript
-}
port measurements : (Word -> msg) -> Sub msg


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = update
        , subscriptions =
            always
                (Sub.batch
                    [ onResize WindowSize
                    , measurements Measured
                    ]
                )
        , onUrlRequest = always Noop
        , onUrlChange = .fragment >> LoadClip
        }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model.initial url.fragment key
    , Cmd.batch
        [ Http.get "/videos.json" Video.videos
            |> Http.send VideosLoad
        , Task.perform (\{ viewport } -> WindowSize (round viewport.width) (round viewport.height)) getViewport
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideosLoad videos ->
            loadClip { model | videos = Result.toMaybe videos }

        PlayRandom ->
            navigateToRandomVideo model

        ShowSoundButton ->
            ( { model | sound = Shown }, Cmd.none )

        EnableSound ->
            ( { model | sound = Enabled }, Cmd.none )

        NavigateTo slug ->
            ( model, Navigation.pushUrl model.key ("#" ++ slug) )

        LoadClip slug ->
            case slug of
                Just slug_ ->
                    loadClip { model | clip = Slug slug_ }

                Nothing ->
                    loadClip { model | clip = Initial }

        Measured word ->
            case model.clip of
                Loaded clip ->
                    let
                        ( newClip, cmd ) =
                            Clip.update word clip
                    in
                    ( { model | clip = Loaded newClip }
                    , case cmd of
                        Just text ->
                            measure { font = Clip.font, text = text }

                        Nothing ->
                            Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        WindowSize width height ->
            ( { model | width = width, height = height }, Cmd.none )

        Noop ->
            ( model, Cmd.none )


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
            , case cmd of
                Just text ->
                    measure { font = Clip.font, text = text }

                Nothing ->
                    Cmd.none
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
