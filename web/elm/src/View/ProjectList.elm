module View.ProjectList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Time exposing (Time)
import Model exposing (ProjectList)
import Msg exposing (Msg)
import View.Project


view : ProjectList -> Maybe Time -> Html Msg
view projectList now =
    if List.isEmpty projectList then
        viewPlaceholder
    else
        div [ class "projects-list" ]
            (List.map (View.Project.view now) projectList)


viewPlaceholder : Html msg
viewPlaceholder =
    div [ class "placeholder" ]
        [ text "There are no projects!" ]
