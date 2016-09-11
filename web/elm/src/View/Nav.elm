module View.Nav exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, title)
import Html.Events exposing (onClick)
import Msg exposing (Msg(Open))


view : String -> Html Msg
view username =
    div
        [ class "nav" ]
        [ a
            [ onClick Open
            , href "#"
            , title "Create a new project and add it to the wall"
            ]
            [ span
                [ class "octicon octicon-plus" ]
                []
            ]
        , span
            [ class "account" ]
            [ span
                [ class "octicon octicon-person" ]
                []
            , strong
                []
                [ text username ]
            ]
        , a
            [ class "octicon octicon-sign-out"
            , href "/logout"
            , title "Sign out"
            ]
            []
        ]
