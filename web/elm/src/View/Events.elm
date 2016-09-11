module View.Events exposing (view)

import Date
import Html exposing (..)
import Html.Attributes exposing (class)
import Model exposing (ProjectList, Project)
import Msg exposing (Msg(..))
import Time exposing (Time)
import Update exposing (deploymentAge)


view : Maybe Time -> ProjectList -> Html Msg
view now projects =
    let
        default =
            div [] []

        output =
            projects
                |> mostRecentlyDeployedProject
                |> Maybe.map (viewDeploymentEvent now)
                |> Maybe.withDefault default
    in
        div
            [ class "events" ]
            [ output ]


viewDeploymentEvent : Maybe Time -> Project -> Html Msg
viewDeploymentEvent now project =
    let
        age =
            project
                |> deploymentAge now
                |> Maybe.withDefault "Unknown"
    in
        div
            [ class "event" ]
            [ div [ class "event__title" ] [ text "Deployment" ]
            , div [ class "event__subject" ] [ text project.name ]
            , div [ class "action action--purple" ] [ text "Deployed" ]
            , div [ class "event__date" ] [ text age ]
            ]


deploymentComparator : Project -> Time
deploymentComparator =
    .latestDeployment >> Maybe.map Date.toTime >> Maybe.withDefault 0


mostRecentlyDeployedProject : ProjectList -> Maybe Project
mostRecentlyDeployedProject projects =
    projects
        |> List.sortBy deploymentComparator
        |> List.reverse
        |> List.head
