module RelativeDate exposing (..)

import Time exposing (Time)


type Ago
    = Years Int
    | Months Int
    | Weeks Int
    | Days Int
    | Hours Int
    | Minutes Int
    | Seconds Int
    | JustNow


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
