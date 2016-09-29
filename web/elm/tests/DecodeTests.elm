module DecodeTests exposing (..)

import Test exposing (..)
import Expect
import Model exposing (..)
import Json.Decode
import Decode
import Date


all : Test
all =
    describe "Decode"
        [ describe "project"
            [ test "Decoding a project JSON" <|
                \() ->
                    let
                        json =
                            """
                         {
                           "id": 1,
                           "name": "project 1",
                           "masterBuildStatus": null,
                           "latestDeployment": null,
                           "latestBuildStatus": null
                         }
                         """

                        project =
                            Project 1 "project 1" Unknown Unknown Nothing

                        result =
                            Json.Decode.decodeString Decode.project json
                    in
                        Expect.equal (Ok project) result
            , test "Decodes a string date into a Maybe Date" <|
                \() ->
                    let
                        json =
                            """
                         {
                           "id": 1,
                           "name": "project 1",
                           "masterBuildStatus": null,
                           "latestDeployment": "2016-12-01T12:00Z",
                           "latestBuildStatus": null
                         }
                         """

                        date =
                            Just (Date.fromTime 1480593600000)

                        project =
                            Project 1 "project 1" Unknown Unknown date

                        result =
                            Json.Decode.decodeString Decode.project json
                    in
                        Expect.equal (Ok project) result
            , test "Decodes build status into types" <|
                \() ->
                    let
                        json =
                            """
                         {
                           "id": 1,
                           "name": "project 1",
                           "masterBuildStatus": "success",
                           "latestDeployment": null,
                           "latestBuildStatus": "pending"
                         }
                         """

                        project =
                            Project 1 "project 1" Success Pending Nothing

                        result =
                            Json.Decode.decodeString Decode.project json
                    in
                        Expect.equal (Ok project) result
            ]
        , describe "token"
            [ test "Decodes a JSON token object" <|
                \() ->
                    let
                        json =
                            "{\"token\": \"abc123\"}"

                        result =
                            Json.Decode.decodeString Decode.token json
                    in
                        Expect.equal (Ok "abc123") result
            ]
        ]
