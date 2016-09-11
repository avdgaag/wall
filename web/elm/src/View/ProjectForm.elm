module View.ProjectForm exposing (view)

import Html exposing (..)
import Html.Attributes
    exposing
        ( href
        , class
        , value
        , type'
        , disabled
        , title
        , id
        , for
        )
import Html.Events
    exposing
        ( onClick
        , onInput
        , onSubmit
        )
import String
import Model exposing (ProjectForm)
import Update exposing (isNew)
import Msg exposing (Msg(..))


view : ProjectForm -> Html Msg
view model =
    let
        modelName =
            Maybe.withDefault "" (fst model.name)

        errors =
            snd model.name

        hasErrors =
            List.isEmpty errors

        inputClassName =
            "input string"
                ++ if hasErrors then
                    ""
                   else
                    " with-errors"
    in
        if model.isOpen then
            div
                [ class "dialog" ]
                [ div
                    [ class "project-form-wrapper" ]
                    [ h2
                        [ class "project-form-title" ]
                        [ text "Create Project" ]
                    , viewPostError model.postError
                    , Html.form
                        [ class "project-form"
                        , onSubmit Submit
                        ]
                        [ div
                            [ class inputClassName
                            ]
                            [ label
                                [ for "project-form-name" ]
                                [ text "Name" ]
                            , input
                                [ id "project-form-name"
                                , type' "text"
                                , onInput SetName
                                , value modelName
                                ]
                                []
                            , ul
                                [ class "errors" ]
                                (List.map
                                    (\error -> li [ class "error" ] [ text error ])
                                    errors
                                )
                            ]
                        , viewToken model
                        , viewFormControls model
                        ]
                    ]
                ]
        else
            div [] []


viewToken : ProjectForm -> Html Msg
viewToken model =
    let
        truncate =
            \n str -> (String.left n str) ++ "..." ++ (String.right n str)

        link =
            case model.generatedToken of
                Just token ->
                    span
                        []
                        [ a
                            [ href ("/api/events/" ++ token)
                            , title "Send events to this URL"
                            , class "token-generator__token"
                            ]
                            [ token |> truncate 10 |> text ]
                        , a
                            [ href "#"
                            , title "Generate a new secret URI to post events to"
                            , onClick GenerateToken
                            ]
                            [ span
                                [ class "octicon octicon-sync" ]
                                []
                            ]
                        ]

                Nothing ->
                    a
                        [ href "#"
                        , title "Generate a new secret URI to post events to"
                        , onClick GenerateToken
                        ]
                        [ text "Generate an API token"
                        ]
    in
        if isNew model then
            div [] []
        else
            div
                [ class "token-generator" ]
                [ span
                    [ class "octicon octicon-shield"
                    ]
                    []
                , link
                ]


viewPostError : Maybe String -> Html Msg
viewPostError msg =
    case msg of
        Just str ->
            ul
                [ class "errors" ]
                [ li
                    [ class "error" ]
                    [ text str ]
                ]

        Nothing ->
            div [] []


viewFormControls : ProjectForm -> Html Msg
viewFormControls model =
    let
        hasErrors =
            case fst model.name of
                Just str ->
                    model.name
                        |> snd
                        |> List.isEmpty
                        |> not

                Nothing ->
                    True

        label =
            if isNew model then
                "Create Project"
            else
                "Update Project"
    in
        if model.waiting then
            div [] [ text "Please wait..." ]
        else
            div
                [ class "controls" ]
                [ input
                    [ type' "submit"
                    , value label
                    , disabled hasErrors
                    ]
                    []
                , text " or "
                , a
                    [ class "cancel"
                    , href "#"
                    , onClick Cancel
                    ]
                    [ text "cancel" ]
                ]
