module View exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (id, class)
import Msg exposing (Msg)
import Model exposing (Model)
import View.ProjectForm
import View.Events
import View.ProjectList
import View.Nav


view : Model -> Html Msg
view model =
    div
        [ id "container"
        , class "wall"
        ]
        [ View.ProjectForm.view model.projectForm
        , View.Nav.view model.user.name
        , View.ProjectList.view model.projects model.now
        , View.Events.view model.now model.projects
        ]
