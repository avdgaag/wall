module Events exposing (..)

import Project exposing (Project)
import ProjectList exposing (ProjectList)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Time exposing (Time)
import Date


deploymentComparator =
    .latestDeployment >> Maybe.map Date.toTime >> Maybe.withDefault 0


mostRecentlyDeployedProject : Maybe Time -> ProjectList -> Maybe Project
mostRecentlyDeployedProject now projects =
    projects
        |> List.sortBy deploymentComparator
        |> List.reverse
        |> List.head


view : Maybe Time -> ProjectList -> Html a
view now projects =
    let
        default =
            div [] []

        output =
            projects
                |> mostRecentlyDeployedProject now
                |> Maybe.map (viewDeploymentEvent now)
                |> Maybe.withDefault default
    in
        div [ class "events" ] [ output ]


viewDeploymentEvent : Maybe Time -> Project -> Html a
viewDeploymentEvent now project =
    let
        age =
            project
                |> Project.deploymentAge now
                |> Maybe.withDefault "Unknown"
    in
        div
            [ class "event" ]
            [ div [ class "event__title" ] [ text "Deployment" ]
            , div [ class "event__subject" ] [ text project.name ]
            , div [ class "action action--purple" ] [ text "Deployed" ]
            , div [ class "event__date" ] [ text age ]
            ]
