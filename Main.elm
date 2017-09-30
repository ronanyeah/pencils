port module Main exposing (main)

import Html exposing (Html)
import Element exposing (column, el, html, viewport)
import Element.Attributes exposing (alignLeft, alignRight, px, moveLeft, moveRight, moveUp)
import Json.Decode
import Json.Encode
import Style exposing (StyleSheet, styleSheet)
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)
import Svg.Events exposing (on, onMouseOver)
import Task
import Window


main : Program Never Model Msg
main =
    Html.program
        { init = ( emptyModel, Task.perform Resize Window.size )
        , subscriptions = always (Window.resizes Resize)
        , update = update
        , view = view
        }


port touchPort : ( Json.Encode.Value, Int ) -> Cmd msg


type alias Model =
    { device : Element.Device
    , open : Int
    }


type Side
    = Left
    | Right


type Styles
    = None


type Msg
    = Resize Window.Size
    | Zip Int
    | Touch Json.Encode.Value


styling : StyleSheet Styles vars
styling =
    styleSheet
        [ Style.style None []
        ]


view : Model -> Html Msg
view { device, open } =
    let
        pBody =
            device.width
                |> toFloat
                |> (*) 0.45
                |> round

        pTip =
            device.width // 10

        pHeight =
            device.height // 15

        rows =
            List.range 0 29
                |> List.map
                    (\i ->
                        let
                            shift =
                                if i /= 0 then
                                    pHeight // 2 |> (*) i |> toFloat
                                else
                                    0

                            xShift =
                                if open > i then
                                    10 * (open - i) |> clamp 0 pBody |> toFloat
                                else
                                    0
                        in
                            if i |> isEven then
                                el None
                                    [ Element.Attributes.height <| px <| toFloat pHeight
                                    , alignLeft
                                    , moveUp shift
                                    , moveLeft xShift
                                    ]
                                <|
                                    html <|
                                        pencil i Left pBody pTip pHeight
                            else
                                el None
                                    [ Element.Attributes.height <| px <| toFloat pHeight
                                    , moveUp shift
                                    , alignRight
                                    , moveRight xShift
                                    ]
                                <|
                                    html <|
                                        pencil i Right pBody pTip pHeight
                    )
    in
        Html.div []
            [ Html.node "style"
                []
                [ Html.text "body { overflow: hidden; }"
                ]
            , viewport styling <|
                column None [] rows
            ]


pencil : Int -> Side -> Int -> Int -> Int -> Html Msg
pencil index side bodyWidth tipWidth pencilHeight =
    let
        tipPoints =
            case side of
                Left ->
                    tip ( bodyWidth, 0 ) ( bodyWidth + tipWidth, pencilHeight // 2 ) ( bodyWidth, pencilHeight )

                Right ->
                    tip ( tipWidth, 0 ) ( 0, pencilHeight // 2 ) ( tipWidth, pencilHeight )

        bodyColor =
            case side of
                Left ->
                    "red"

                Right ->
                    "blue"

        tipColor =
            case side of
                Left ->
                    "green"

                Right ->
                    "yellow"

        bodyShift =
            case side of
                Left ->
                    "0"

                Right ->
                    toString tipWidth

        border =
            SA.style "stroke: purple; stroke-width: 1"
    in
        svg [ SA.height <| toString pencilHeight, SA.width <| toString (bodyWidth + tipWidth), SA.id <| toString index ]
            [ rect
                [ SA.width <| toString bodyWidth
                , SA.height <| toString pencilHeight
                , SA.fill bodyColor
                , border
                , x bodyShift
                ]
                []
            , polygon
                [ points tipPoints
                , SA.fill tipColor
                , border
                , onMouseOver <| Zip index
                , on "touchmove" <| Json.Decode.map Touch Json.Decode.value
                ]
                []
            ]


isEven : Int -> Bool
isEven =
    flip (%) 2
        >> (==) 0


tip : ( Int, Int ) -> ( Int, Int ) -> ( Int, Int ) -> String
tip a b c =
    let
        point ( d, e ) =
            toString d ++ "," ++ toString e
    in
        point a ++ " " ++ point b ++ " " ++ point c


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            { model | device = Element.classifyDevice size } ! []

        Zip i ->
            let
                open =
                    if i == model.open - 1 || i == model.open + 1 then
                        i
                    else
                        model.open
            in
                { model | open = open } ! []

        Touch e ->
            model ! [ touchPort ( e, model.open ) ]


emptyModel : Model
emptyModel =
    { device =
        { width = 0
        , height = 0
        , phone = False
        , tablet = False
        , desktop = False
        , bigDesktop = False
        , portrait = False
        }
    , open = 0
    }
