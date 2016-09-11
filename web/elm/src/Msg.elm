module Msg exposing (Msg(..))

import Model exposing (..)
import Http
import Time exposing (Time)


type Msg
    = NoOp
    | Tick Time
    | ProjectCreated Project
    | ProjectUpdated Project
    | ProjectDestroyed Project
    | FetchFailed Http.Error
    | FetchSucceeded ProjectList
    | DestroyFailed Http.Error
    | DestroySucceeded String
    | CreateFailed Http.Error
    | CreateSucceeded String
    | UpdateFailed Http.Error
    | UpdateSucceeded String
    | GetTokenFailed Http.Error
    | GetTokenSucceeded String
    | DestroyProject Project
    | SetName String
    | Submit
    | Cancel
    | Open
    | Edit Project
    | GenerateToken
