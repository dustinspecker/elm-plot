module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (transform, height, width, style, d, x, y, x1, x2, y1, y2)
import String
import Debug


getHighest : List Float -> Float
getHighest values =
    Maybe.withDefault 1 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
    min 0 (Maybe.withDefault 0 (List.minimum values))


coordToInstruction : String -> List ( Float, Float ) -> String
coordToInstruction instructionType coords =
    List.map (\( x, y ) -> toInstruction instructionType [ x, y ]) coords |> String.join ""


toInstruction : String -> List Float -> String
toInstruction instructionType coords =
    let
        coordsString =
            List.map toString coords
                |> String.join ","
    in
        instructionType ++ " " ++ coordsString


startPath : List ( Float, Float ) -> ( String, List ( Float, Float ) )
startPath data =
    let
        ( x, y ) =
            Maybe.withDefault ( 0, 0 ) (List.head data)

        tail =
            Maybe.withDefault [] (List.tail data)
    in
        ( toInstruction "M" [ x, y ], tail )


toPositionAttr : Float -> Float -> Float -> Float -> List (Svg.Attribute msg)
toPositionAttr x1 y1 x2 y2 =
    [ Svg.Attributes.x1 (toString x1)
    , Svg.Attributes.y1 (toString y1)
    , Svg.Attributes.x2 (toString x2)
    , Svg.Attributes.y2 (toString y2)
    ]


toTranslate : ( Float, Float ) -> String
toTranslate ( x, y ) =
    "translate(" ++ (toString x) ++ "," ++ (toString y) ++ ")"


toRotate : Float -> Float -> Float -> String
toRotate d x y =
    "rotate(" ++ (toString d) ++ " " ++ (toString x) ++ " " ++ (toString y) ++ ")"


toStyle : List ( String, String ) -> String
toStyle styles =
    List.foldr (\( p, v ) r -> r ++ p ++ ":" ++ v ++ "; ") "" styles


calculateStep : Float -> Float
calculateStep targetStep =
    let
        -- calculate an initial guess at step size
        tempStep =
            targetStep

        -- get the magnitude of the step size
        mag =
            floor (logBase 10 tempStep)

        magPow =
            toFloat (10 ^ mag)

        -- calculate most significant digit of the new step size
        magMsd =
            round (tempStep / magPow)

        -- promote the MSD to either 1, 2, or 5
        magMsdFinal =
            if magMsd > 5 then
                10
            else if magMsd > 2 then
                5
            else if magMsd > 1 then
                1
            else
                magMsd
    in
        (toFloat magMsdFinal) * magPow
