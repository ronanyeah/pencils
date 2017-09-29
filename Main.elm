module Main exposing (main)

import Html exposing (Html)
import Element exposing (Attribute, Element, button, column, el, empty, html, image, paragraph, row, text, screen, viewport, when)
import Element.Attributes exposing (alignBottom, alignLeft, attribute, center, class, fill, height, id, padding, px, spacing, maxHeight, maxWidth, moveDown, moveLeft, moveRight, moveUp, verticalCenter, width, percent, vary, scrollbars)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)
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


type alias Model =
    { device : Element.Device
    }


type Pencil
    = Left Int Int Int
    | Right Int Int Int


type Styles
    = None


type Msg
    = Resize Window.Size


styling : StyleSheet Styles vars
styling =
    styleSheet
        [ Style.style None []
        ]


view : Model -> Html Msg
view { device } =
    let
        pBody =
            device.width
                |> toFloat
                |> flip (/) 2
                |> (*) 0.9
                |> round

        pTip =
            device.width
                |> toFloat
                |> flip (/) 2
                |> (*) 0.1
                |> round

        pHeight =
            device.height
                |> flip (//) 15

        rows =
            List.range 0 14
                |> List.map
                    (\_ ->
                        row None
                            [ Element.Attributes.height <| px <| toFloat pHeight ]
                            [ el None [ moveRight (pTip // 2 |> toFloat), Element.Attributes.height <| px <| toFloat pHeight ] <|
                                html <|
                                    pencil (Left pBody pTip pHeight)
                            , el None [ moveDown <| (pHeight // 2 |> toFloat), moveLeft (pTip // 2 |> toFloat), Element.Attributes.height <| px <| toFloat pHeight ] <|
                                html <|
                                    pencil (Right pBody pTip pHeight)
                            ]
                    )
    in
        viewport styling <|
            column None [] rows


pencil : Pencil -> Html Msg
pencil p =
    let
        border =
            SA.style "stroke: purple; stroke-width: 1"

        pTip =
            case p of
                Left bodyWidth tipWidth pHeight ->
                    polygon
                        [ points <| tip ( bodyWidth, 0 ) ( bodyWidth + tipWidth, pHeight // 2 ) ( bodyWidth, pHeight )
                        , SA.fill "red"
                        , border
                        ]
                        []

                Right bodyWidth tipWidth pHeight ->
                    polygon
                        [ points <| tip ( tipWidth, 0 ) ( 0, pHeight // 2 ) ( tipWidth, pHeight )
                        , SA.fill "blue"
                        , border
                        ]
                        []

        ( pHeight, pWidth ) =
            case p of
                Left b t h ->
                    ( toString h, toString (b + t) )

                Right b t h ->
                    ( toString h, toString (b + t) )

        body =
            case p of
                Left b _ h ->
                    rect [ SA.width <| toString b, SA.height <| toString h, SA.fill "green", border ] []

                Right b t h ->
                    rect [ x <| toString t, y "0", SA.width <| toString b, SA.height <| toString h, SA.fill "yellow", border ] []
    in
        svg [ SA.height pHeight, SA.width pWidth ]
            [ body
            , pTip
            ]


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
    }
