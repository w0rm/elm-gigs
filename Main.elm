port module Gigs exposing (main)

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


{-| port for sending text to measure out to JavaScript
-}
port measure : { font : String, text : String } -> Cmd msg


{-| port for listening for measurements from JavaScript
-}
port measurements : (Word -> msg) -> Sub msg


main : Program Never Model Msg
main =
    Navigation.program
        (.hash >> String.dropLeft 1 >> LoadClip)
        { init = .hash >> String.dropLeft 1 >> init
        , view = View.view
        , update = update
        , subscriptions =
            always
                (Sub.batch
                    [ Window.resizes WindowSize
                    , measurements Measured
                    ]
                )
        }


init : String -> ( Model, Cmd Msg )
init slug =
    ( Model.initial slug
    , Cmd.batch
        [ Http.get "/videos.json" Video.videos
            |> Http.send VideosLoad
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
