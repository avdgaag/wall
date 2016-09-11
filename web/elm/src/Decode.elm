module Decode
    exposing
        ( project
        , parseRawProject
        , token
        , emptyStringDecoder
        , projectsData
        )

import Json.Decode exposing ((:=))
import Model exposing (..)
import Date exposing (Date)


-- Parsing projects


project : Json.Decode.Decoder Project
project =
    Json.Decode.object5 Project
        ("id" := Json.Decode.int)
        ("name" := Json.Decode.string)
        ("masterBuildStatus" := buildStatusDecoder)
        ("latestBuildStatus" := buildStatusDecoder)
        ("latestDeployment" := decodeMaybeDate)


projects : Json.Decode.Decoder ProjectList
projects =
    Json.Decode.list project


parseRawProject : RawProject -> Project
parseRawProject inputProject =
    let
        masterBuildStatus =
            inputProject
                |> .masterBuildStatus
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestBuildStatus =
            inputProject
                |> .latestBuildStatus
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestDeployment =
            inputProject
                |> .latestDeployment
                |> parseMaybeDate
                |> Result.withDefault Nothing
    in
        Project inputProject.id inputProject.name masterBuildStatus latestBuildStatus latestDeployment


projectsData : Json.Decode.Decoder ProjectList
projectsData =
    Json.Decode.at [ "data" ] projects


token : Json.Decode.Decoder String
token =
    Json.Decode.at [ "token" ] Json.Decode.string



-- Parsing project build status


parseBuildStatus : Maybe String -> Result String BuildStatus
parseBuildStatus value =
    case value of
        Just "success" ->
            Ok Success

        Just "failed" ->
            Ok Failed

        Just "pending" ->
            Ok Pending

        Nothing ->
            Ok Unknown

        Just _ ->
            Err "Unexpected build status encountered"


buildStatusDecoder : Json.Decode.Decoder BuildStatus
buildStatusDecoder =
    Json.Decode.customDecoder maybeStringDecoder parseBuildStatus



-- Utilities


decodeMaybeDate : Json.Decode.Decoder (Maybe Date)
decodeMaybeDate =
    Json.Decode.customDecoder maybeStringDecoder parseMaybeDate


emptyStringDecoder : Json.Decode.Decoder String
emptyStringDecoder =
    Json.Decode.succeed ""


maybeStringDecoder : Json.Decode.Decoder (Maybe String)
maybeStringDecoder =
    Json.Decode.oneOf
        [ (Json.Decode.null Nothing)
        , Json.Decode.map Just Json.Decode.string
        ]


parseMaybeDate : Maybe String -> Result String (Maybe Date)
parseMaybeDate value =
    case value of
        Nothing ->
            Ok Nothing

        Just str ->
            str
                |> Date.fromString
                |> Result.map Just
