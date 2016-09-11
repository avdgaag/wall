module Api exposing (getAll, create, update, destroy, eventToken)

import Decode
import Http
import Model exposing (..)
import Msg exposing (..)
import Task


multipartParams : List ( String, String ) -> Http.Body
multipartParams params =
    let
        toStringData =
            \( k, v ) -> Http.stringData k v
    in
        params
            |> List.map toStringData
            |> Http.multipart


post : String -> (Http.Error -> Msg) -> (String -> Msg) -> List ( String, String ) -> Cmd Msg
post url failureMsg successMsg params =
    params
        |> multipartParams
        |> Http.post Decode.emptyStringDecoder url
        |> Task.perform failureMsg successMsg


getAll : String -> Cmd Msg
getAll token =
    let
        url =
            Http.url "/api/projects" [ ( "token", token ) ]
    in
        url
            |> Http.get Decode.projectsData
            |> Task.perform FetchFailed FetchSucceeded


create : String -> String -> Cmd Msg
create token name =
    let
        params =
            [ ( "project[name]", name )
            , ( "token", token )
            ]
    in
        post "/api/projects" CreateFailed CreateSucceeded params


update : String -> Project -> Cmd Msg
update token project =
    let
        params =
            [ ( "project[name]", project.name )
            , ( "_method", "patch" )
            , ( "token", token )
            ]

        url =
            "/api/projects/" ++ (toString project.id)
    in
        post url UpdateFailed UpdateSucceeded params


destroy : String -> Project -> Cmd Msg
destroy token project =
    let
        url =
            "/api/projects/" ++ (toString project.id)

        params =
            [ ( "_method", "delete" )
            , ( "token", token )
            ]
    in
        post url DestroyFailed DestroySucceeded params


eventToken : String -> Project -> Cmd Msg
eventToken token project =
    let
        url =
            Http.url ("/api/projects/" ++ (toString project.id) ++ "/token") [ ( "token", token ) ]
    in
        url
            |> Http.get Decode.token
            |> Task.perform GetTokenFailed GetTokenSucceeded
