module Model
    exposing
        ( Flags
        , Model
        , RawProject
        , Project
        , Ago(..)
        , ProjectList
        , ProjectForm
        , Attribute
        , Errors
        , BuildStatus(..)
        )

import Date exposing (Date)
import Time exposing (Time)


{-| Type for indicating a time range so we can show a relative time distance,
such as "2 weeks ago".
-}
type Ago
    = Years Int
    | Months Int
    | Weeks Int
    | Days Int
    | Hours Int
    | Minutes Int
    | Seconds Int
    | JustNow


type alias Model =
    { projects : ProjectList
    , projectForm : ProjectForm
    , user : User
    , now : Maybe Time
    }


{-| The currently logged in user that can make authenticated requests to the
remote API.
-}
type alias User =
    { name : String
    , token : String
    }


{-| Program flags that are required when we launch this Elm app. These are
supplied in the native Javascript code to start this app.
-}
type alias Flags =
    User



-- Project


{-| A list of projects that we can update based on remote requests.
-}
type alias ProjectList =
    List Project


{-| Most important basic type in the app, representing a project on the status
wall (a single row) with various status properties.
-}
type alias Project =
    { id : Int
    , name : String
    , masterBuildStatus : BuildStatus
    , latestBuildStatus : BuildStatus
    , latestDeployment : Maybe Date
    }


{-| The RawProject is a type that comes in through a port. Elm handles the JSON
decoding for us, but we need this intermediary type to go from Elm primitives to
a `Project` type.
-}
type alias RawProject =
    { id : Int
    , name : String
    , masterBuildStatus : Maybe String
    , latestBuildStatus : Maybe String
    , latestDeployment : Maybe String
    }


{-| A BuildStatus represents the possible values for the various build status
aspects of a project.
-}
type BuildStatus
    = Success
    | Failed
    | Pending
    | Unknown



-- Project form


{-| Validations errors for a particular attribute in a form.
-}
type alias Errors =
    List String


{-| An attribute of a model in a form, representing a string-based value and
possible validation errors.
-}
type alias Attribute =
    ( Maybe String, Errors )


{-| A form to edit or create a `Project` type. It currently includes state for
remote request results and the dialog it is presented in.
-}
type alias ProjectForm =
    { name : Attribute
    , waiting : Bool
    , postError : Maybe String
    , id : Maybe Int
    , isOpen : Bool
    , token : String
    , generatedToken : Maybe String
    }
