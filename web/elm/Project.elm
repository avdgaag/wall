module Project exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, title, id)
import Html.Events exposing (onClick)
import Json.Decode as Json exposing ((:=))
import Date exposing (Date)
import Time exposing (Time)
import RelativeDate exposing (Ago(..))


-- MODEL


type alias Project =
    { id : Int
    , name : String
    , masterBuildStatus : BuildStatus
    , latestBuildStatus : BuildStatus
    , latestDeployment : Maybe Date
    }


type alias RawProject =
    { id : Int
    , name : String
    , masterBuildStatus : Maybe String
    , latestBuildStatus : Maybe String
    , latestDeployment : Maybe String
    }


type BuildStatus
    = Success
    | Failed
    | Pending
    | Unknown


type Msg
    = NoOp
    | EditProjectForm Project
    | DestroyProject Project



-- UPDATE


update : Msg -> Project -> Project
update msg model =
    case msg of
        NoOp ->
            model

        EditProjectForm project ->
            model

        DestroyProject project ->
            model



-- VIEW


view : Maybe Time -> Project -> Html Msg
view now project =
    let
        domId =
            "project-" ++ (toString project.id)
    in
        div
            [ id domId
            , class "project"
            ]
            [ viewBuildStatus project
            , viewTitle project.name
            , viewDeployment now project.latestDeployment
            , viewControls project
            ]


minibutton : String -> String -> msg -> Html msg
minibutton icon description msg =
    a
        [ class "minibutton"
        , title description
        , onClick msg
        ]
        [ span
            [ class ("octicon octicon-" ++ icon) ]
            []
        ]


translateTimeAgo : Ago -> String
translateTimeAgo ago =
    case ago of
        Years i ->
            (toString i) ++ " years ago"

        Months i ->
            (toString i) ++ " months ago"

        Weeks i ->
            (toString i) ++ " weeks ago"

        Days i ->
            (toString i) ++ " days ago"

        Hours i ->
            (toString i) ++ " hours ago"

        Minutes i ->
            (toString i) ++ " minutes ago"

        Seconds i ->
            (toString i) ++ " seconds ago"

        JustNow ->
            "just now"


viewDeployment : Maybe Time -> Maybe Date -> Html Msg
viewDeployment now date =
    let
        result =
            date
                |> Maybe.map Date.toTime
                |> Maybe.map2 RelativeDate.timeAgoInWords now
                |> Maybe.map translateTimeAgo
    in
        case result of
            Nothing ->
                div [] []

            Just result ->
                div
                    [ class "project__deployment" ]
                    [ text result ]


viewControls : Project -> Html Msg
viewControls project =
    div [ class "project__controls" ]
        [ minibutton "gear" "Remove this project" (EditProjectForm project)
        , minibutton "trashcan" "Remove this project" (DestroyProject project)
        ]


viewTitle : String -> Html Msg
viewTitle name =
    div [ class "project__title" ]
        [ text name ]


viewBuildStatus : Project -> Html Msg
viewBuildStatus project =
    div [ class "project__build-status" ]
        [ viewBuildBadge "primitive-dot" project.masterBuildStatus
        , viewBuildBadge "git-branch" project.latestBuildStatus
        ]


viewBuildBadge : String -> BuildStatus -> Html Msg
viewBuildBadge icon buildStatus =
    let
        className =
            case buildStatus of
                Success ->
                    "badge--green"

                Failed ->
                    "badge--red"

                Pending ->
                    "badge--yellow"

                Unknown ->
                    "badge--gray"
    in
        span
            [ class ("badge " ++ className)
            ]
            [ i
                [ class ("mega-octicon octicon-" ++ icon) ]
                []
            ]



-- DECODING


decoder : Json.Decoder Project
decoder =
    Json.object5 Project
        ("id" := Json.int)
        ("name" := Json.string)
        ("masterBuildStatus" := buildStatusDecoder)
        ("latestBuildStatus" := buildStatusDecoder)
        ("latestDeployment" := latestDeploymentDecoder)


parseBuildStatus : String -> Result String BuildStatus
parseBuildStatus value =
    case value of
        "success" ->
            Ok Success

        "failed" ->
            Ok Failed

        "pending" ->
            Ok Pending

        "" ->
            Ok Unknown

        _ ->
            Err "Unexpected build status encountered"


parseLatestDeployment : Maybe String -> Result String (Maybe Date)
parseLatestDeployment value =
    case value of
        Nothing ->
            Ok Nothing

        Just str ->
            str
                |> Date.fromString
                |> Result.map Just


latestDeploymentDecoder : Json.Decoder (Maybe Date)
latestDeploymentDecoder =
    let
        nullOrStringDecoder =
            Json.oneOf
                [ (Json.null Nothing)
                , Json.map Just Json.string
                ]
    in
        Json.customDecoder nullOrStringDecoder parseLatestDeployment


buildStatusDecoder : Json.Decoder BuildStatus
buildStatusDecoder =
    let
        nullOrStringDecoder =
            Json.oneOf [ (Json.null ""), Json.string ]
    in
        Json.customDecoder nullOrStringDecoder parseBuildStatus


parseRawProject : RawProject -> Project
parseRawProject inputProject =
    let
        masterBuildStatus =
            inputProject.masterBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestBuildStatus =
            inputProject.latestBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestDeployment =
            inputProject.latestDeployment
                |> parseLatestDeployment
                |> Result.withDefault Nothing
    in
        Project inputProject.id inputProject.name masterBuildStatus latestBuildStatus latestDeployment
