module Update
    exposing
        ( update
        , isNew
        , deploymentAge
        )

import Api
import Date
import Http
import Model exposing (..)
import Msg exposing (Msg(..))
import Ports
import String
import Time exposing (Time)
import Update.ProjectList


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Tick time ->
            { model
                | now = Just time
            }
                ! []

        FetchSucceeded projects ->
            { model
                | projects = Update.ProjectList.sort projects
            }
                ! []

        ProjectDestroyed project ->
            { model
                | projects = Update.ProjectList.remove project model.projects
            }
                ! []

        ProjectCreated project ->
            { model
                | projects = Update.ProjectList.append project model.projects
            }
                ! []

        ProjectUpdated project ->
            { model
                | projects = Update.ProjectList.append project model.projects
            }
                ! []

        DestroyProject project ->
            model ! [ Api.destroy model.user.token project ]

        Open ->
            let
                projectFormModel =
                    model.projectForm
            in
                { model
                    | projectForm = { projectFormModel | isOpen = True }
                }
                    ! [ Ports.focus "#project-form-name" ]

        Edit project ->
            { model
                | projectForm = fromProject project model.projectForm
            }
                ! [ Ports.focus "#project-form-name" ]

        SetName str ->
            let
                projectForm =
                    model.projectForm

                updatedProjectForm =
                    { projectForm
                        | name = ( Just str, (validatePresence str) )
                    }
            in
                { model
                    | projectForm = updatedProjectForm
                }
                    ! []

        Submit ->
            let
                projectForm =
                    model.projectForm

                effects =
                    if isNew projectForm then
                        projectForm
                            |> attr .name
                            |> Api.create projectForm.token
                    else
                        case toProject projectForm of
                            Ok project ->
                                project
                                    |> Api.update projectForm.token

                            Err str ->
                                Cmd.none

                updatedProjectForm =
                    { projectForm
                        | waiting = True
                    }
            in
                if isValid projectForm then
                    { model
                        | projectForm = projectForm
                    }
                        ! [ effects ]
                else
                    model ! []

        Cancel ->
            model ! []

        GenerateToken ->
            let
                effects =
                    case toProject model.projectForm of
                        Ok project ->
                            project
                                |> Api.eventToken model.projectForm.token

                        Err str ->
                            Cmd.none
            in
                model ! [ effects ]

        CreateFailed error ->
            let
                projectForm =
                    model.projectForm
            in
                { model
                    | projectForm = addHttpError error projectForm
                }
                    ! []

        UpdateFailed error ->
            let
                projectForm =
                    model.projectForm
            in
                { model
                    | projectForm = addHttpError error projectForm
                }
                    ! []

        GetTokenFailed error ->
            let
                projectForm =
                    model.projectForm
            in
                { model
                    | projectForm = addHttpError error projectForm
                }
                    ! []

        GetTokenSucceeded token ->
            let
                projectForm =
                    model.projectForm

                updatedProjectForm =
                    { projectForm
                        | generatedToken = Just token
                    }
            in
                { model
                    | projectForm = updatedProjectForm
                }
                    ! []

        FetchFailed err ->
            model ! []

        DestroyFailed err ->
            model ! []

        DestroySucceeded body ->
            model ! []

        UpdateSucceeded body ->
            model ! []

        CreateSucceeded body ->
            model ! []



-- Project functions


deploymentAge : Maybe Time -> Project -> Maybe String
deploymentAge now project =
    project
        |> .latestDeployment
        |> Maybe.map Date.toTime
        |> Maybe.map2 timeAgoInWords now
        |> Maybe.map translateTimeAgo



-- Project form functions


fromProject : Project -> ProjectForm -> ProjectForm
fromProject project projectForm =
    { projectForm
        | name = ( Just project.name, [] )
        , id = Just project.id
        , isOpen = True
    }


toProject : ProjectForm -> Result String Project
toProject projectForm =
    let
        name =
            attr .name projectForm
    in
        case projectForm.id of
            Just id ->
                Ok <| Project id name Unknown Unknown Nothing

            Nothing ->
                Err "could not create Project without an ID"


isNew : ProjectForm -> Bool
isNew model =
    case model.id of
        Just _ ->
            False

        Nothing ->
            True


isValid : ProjectForm -> Bool
isValid model =
    let
        hasErrors =
            model.name
                |> snd
                |> List.isEmpty

        isFilledOut =
            case fst model.name of
                Just str ->
                    True

                Nothing ->
                    False
    in
        hasErrors && isFilledOut


validatePresence : String -> Errors
validatePresence str =
    if String.isEmpty str then
        [ "is required" ]
    else
        []


attr : (ProjectForm -> Attribute) -> ProjectForm -> String
attr fun model =
    model
        |> fun
        |> fst
        |> Maybe.withDefault ""


addError : String -> ProjectForm -> ProjectForm
addError desc model =
    { model
        | waiting = False
        , postError = Just desc
    }


addHttpError : Http.Error -> ProjectForm -> ProjectForm
addHttpError error model =
    case error of
        Http.BadResponse code status ->
            addError "The endpoint was not found" model

        _ ->
            addError "An unknown error occured." model



-- Relative time


{-| Calculate the distance between two times in words. This does not
actually return a string with a human-friendly description; a return
value of `Ago` is used so you can generate user-facing strings in your
language of choice.
-}
timeAgoInWords : Time -> Time -> Ago
timeAgoInWords from to =
    let
        difference =
            abs (from - to)

        hours =
            Time.inHours difference

        days =
            hours / 24

        weeks =
            days / 7

        months =
            days / 30

        years =
            months / 12

        minutes =
            Time.inMinutes difference

        seconds =
            Time.inSeconds difference
    in
        if years >= 1 then
            Years <| round years
        else if months >= 1 then
            Months <| round months
        else if weeks >= 1 then
            Weeks <| round weeks
        else if days >= 1 then
            Days <| round days
        else if hours >= 1 then
            Hours <| round hours
        else if minutes >= 1 then
            Minutes <| round minutes
        else if seconds >= 10 then
            Seconds <| round seconds
        else
            JustNow


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
