module View.Project exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, title, id)
import Html.Events exposing (onClick)
import Model exposing (Project, BuildStatus(..))
import Msg exposing (Msg(..))
import Time exposing (Time)
import Update exposing (deploymentAge)


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
            , viewDeployment now project
            , viewControls project
            ]


minibutton : String -> String -> Msg -> Html Msg
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


viewDeployment : Maybe Time -> Project -> Html Msg
viewDeployment now project =
    case deploymentAge now project of
        Nothing ->
            div [] []

        Just result ->
            div
                [ class "project__deployment" ]
                [ text result ]


viewControls : Project -> Html Msg
viewControls project =
    div [ class "project__controls" ]
        [ minibutton "gear" "Remove this project" (Edit project)
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
