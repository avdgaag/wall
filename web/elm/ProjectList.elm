module ProjectList exposing (..)

import Project exposing (Project, Msg)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Time exposing (Time)


-- MODEL


type alias ProjectList =
    List Project


initialModel : ProjectList
initialModel =
    []



-- FUNCTIONS


sort : ProjectList -> ProjectList
sort projectList =
    List.sortBy .id projectList


byId : Project -> Project -> Bool
byId project1 project2 =
    project1.id == project2.id


remove : Project -> ProjectList -> ProjectList
remove project projectList =
    projectList
        |> List.filter (not << byId project)


append : Project -> ProjectList -> ProjectList
append project projectList =
    projectList
        |> List.filter (not << byId project)
        |> List.append [ project ]
        |> sort


length : ProjectList -> Int
length projectList =
    List.length projectList


isEmpty : ProjectList -> Bool
isEmpty projectList =
    List.isEmpty projectList



-- VIEW


view : ProjectList -> Maybe Time -> Html Project.Msg
view projectList now =
    if isEmpty projectList then
        viewPlaceholder
    else
        div [ class "projects-list" ]
            (List.map (Project.view now) projectList)


viewPlaceholder : Html msg
viewPlaceholder =
    div [ class "placeholder" ]
        [ text "There are no projects!" ]
