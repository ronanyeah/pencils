module Main exposing (main)

import Html exposing (Html)
import Element exposing (Attribute, Element, button, column, el, empty, html, image, paragraph, row, text, screen, viewport, when)
import Element.Attributes exposing (alignBottom, alignLeft, alignRight, attribute, center, class, fill, height, id, padding, px, spacing, maxHeight, maxWidth, moveDown, moveLeft, moveRight, moveUp, verticalCenter, width, percent, vary, scrollbars)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)
import Svg.Events exposing (onMouseOver)
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
    , open : Int
    }


type Side
    = Left
    | Right


type Pencil
    = Pencil Side Int Int Int


type Styles
    = None


type Msg
    = Resize Window.Size
    | Zip Int


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
                                        pencil i (Pencil Left pBody pTip pHeight)
                            else
                                el None
                                    [ Element.Attributes.height <| px <| toFloat pHeight
                                    , moveUp shift
                                    , alignRight
                                    , moveRight xShift
                                    ]
                                <|
                                    html <|
                                        pencil i (Pencil Right pBody pTip pHeight)
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


pencil : Int -> Pencil -> Html Msg
pencil i p =
    let
        border =
            SA.style "stroke: purple; stroke-width: 1"

        pTip =
            case p of
                Pencil Left bodyWidth tipWidth pHeight ->
                    polygon
                        [ points <| tip ( bodyWidth, 0 ) ( bodyWidth + tipWidth, pHeight // 2 ) ( bodyWidth, pHeight )
                        , SA.fill "red"
                        , border
                        , onMouseOver <| Zip i
                        ]
                        []

                Pencil Right bodyWidth tipWidth pHeight ->
                    polygon
                        [ points <| tip ( tipWidth, 0 ) ( 0, pHeight // 2 ) ( tipWidth, pHeight )
                        , SA.fill "blue"
                        , border
                        , onMouseOver <| Zip i
                        ]
                        []

        ( pHeight, pWidth ) =
            case p of
                Pencil Left b t h ->
                    ( toString h, toString (b + t) )

                Pencil Right b t h ->
                    ( toString h, toString (b + t) )

        body =
            case p of
                Pencil Left b _ h ->
                    rect [ SA.width <| toString b, SA.height <| toString h, SA.fill "green", border ] []

                Pencil Right b t h ->
                    rect [ x <| toString t, y "0", SA.width <| toString b, SA.height <| toString h, SA.fill "yellow", border ] []
    in
        svg [ SA.height pHeight, SA.width pWidth ]
            [ body
            , pTip
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


isNext : ( Side, Int ) -> ( Side, Int ) -> Bool
isNext ( currSide, currInt ) ( newSide, newInt ) =
    case currSide of
        Left ->
            newSide == Right && currInt == newInt

        Right ->
            newSide == Left && newInt == (currInt + 1)


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
