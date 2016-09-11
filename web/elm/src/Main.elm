module Main exposing (main)

import Api
import Decode exposing (parseRawProject)
import Html.App
import Model exposing (Flags, Model)
import Msg exposing (Msg(Tick, ProjectDestroyed, ProjectUpdated, ProjectCreated))
import Ports
import Time
import Update
import View


init : Flags -> ( Model, Cmd Msg )
init user =
    let
        effects =
            [ Api.getAll user.token
            ]

        projectFormModel =
            { name = ( Nothing, [] )
            , waiting = False
            , postError = Nothing
            , id = Nothing
            , isOpen = False
            , token = user.token
            , generatedToken = Nothing
            }

        initialModel =
            Model [] projectFormModel user Nothing
    in
        initialModel ! effects



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newProjectNotifications (ProjectCreated << parseRawProject)
        , Ports.updateProjectNotifications (ProjectUpdated << parseRawProject)
        , Ports.deleteProjectNotifications (ProjectDestroyed << parseRawProject)
        , Time.every Time.second Tick
        ]



-- Wiring


main : Program Flags
main =
    Html.App.programWithFlags
        { update = Update.update
        , view = View.view
        , init = init
        , subscriptions = subscriptions
        }
