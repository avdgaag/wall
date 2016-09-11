module Update.ProjectList exposing (..)

import Model exposing (ProjectList, Project)


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
