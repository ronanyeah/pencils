module Main exposing (main)

import Html exposing (Html)
import Element exposing (Attribute, Element, button, column, el, empty, html, image, paragraph, row, text, screen, viewport, when)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task
import Window


main : Program Never Model Msg
main =
    Html.program
        { init = ( emptyModel, Task.perform Resize Window.size )
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


type alias Model =
    { device : Element.Device
    }


type Styles
    = None


type Msg
    = Resize Window.Size


styling : StyleSheet Styles vars
styling =
    styleSheet
        [ Style.style None [] ]


view : Model -> Html Msg
view model =
    let
        rows =
            List.range 0 5
                |> List.map
                    (\_ ->
                        row None
                            []
                            [ html <|
                                svg [ height "100" ]
                                    [ rect [ width "200", height "100", fill "#BBC42A" ] []
                                    , polygon
                                        [ points "200,0 250,50 200,100"
                                        , Svg.Attributes.style "fill: #BBC42A;"
                                        ]
                                        []
                                    ]
                            , html <|
                                svg [ height "100" ]
                                    [ polygon
                                        [ points "200,0 250,50 200,100"
                                        , Svg.Attributes.style "fill: #BBC42A;"
                                        ]
                                        []
                                    , rect [ width "200", height "100", fill "#BBC42A" ] []
                                    ]
                            ]
                    )
    in
        viewport styling <|
            column None [] rows


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            { model | device = Element.classifyDevice size } ! []


pencil =
    svg [ height "600", width "600" ]
        [ g []
            [ g [ stroke "#000000", fill "none" ]
                [ Svg.path
                    [ d "m70.064 422.35 374.27-374.26 107.58 107.58-374.26 374.27-129.56 21.97z"
                    , strokeWidth "30"
                    ]
                    []
                , Svg.path [ d "m70.569 417.81 110.61 110.61", strokeWidth "25" ] []
                , Svg.path [ d "m491.47 108.37-366.69 366.68", strokeWidth "25" ] []
                , Svg.path [ d "m54.222 507.26 40.975 39.546", strokeWidth "25" ] []
                ]
            ]
        ]


circ =
    svg [ viewBox "0 0 100 100", width "300px" ]
        [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
        , line
            [ x1 "50"
            , y1 "50"
            , x2 <| toString (50 + 40 * cos 0)
            , y2 <| toString (50 + 40 * sin 0)
            , stroke "#023963"
            ]
            []
        ]


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
