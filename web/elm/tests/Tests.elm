module Tests exposing (..)

import Test exposing (..)
import DecodeTests


all : Test
all =
    describe "A Test Suite"
        [ DecodeTests.all
        ]
