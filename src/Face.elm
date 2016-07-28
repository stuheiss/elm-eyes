import Eye
import Collage
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Html.App as Html
import Html.Lazy
import Mouse
import Window
import Element exposing (Element)
import Time exposing (Time, second, now)
import Task


-- MODEL

-- initial eye positions
(leftEyeX, leftEyeY) = (-75, 50)
(rightEyeX, rightEyeY) = (75, 0)


type alias Model =
  { leftEye : Eye.Model
  , rightEye : Eye.Model
  , width : Int
  , height : Int
  , visibility: Visibility
  , clicks: Int
  , leftEyeXY : {x:Float, y:Float}
  , rightEyeXY : {x:Float, y:Float}
  }


-- Only display the model after an initial `Resize' action
type Visibility = Hidden | Visible


-- VIEW

view : Model -> Html Msg
view model =
  Html.Lazy.lazy viewFace model

rickrolled = "https://www.youtube.com/watch?v=xfr64zoBTAQ"

{-
youtube : String -> Html
youtube url =
  div [class "embed-responsive embed-responsive-16by9"]
  [iframe [class "embed-responsive-item"
          ,src url]
          []]
-}

viewFace : Model -> Html Msg
viewFace model =
  case model.visibility of
    Hidden -> Html.div [] [text "hidden"]
    Visible ->
      div [] [
          table [] [
            tr [] [
                td [] [
                    text ("Clicks: " ++ (toString model.clicks))
                ]
              , td [] [
                    table [] [
                      tr [] [ td [] [text ""], td [] [button [onClick LeftEyeUp] [text "^"]], td [] [text ""] ]
                    , tr [] [ td [] [ button [onClick LeftEyeLeft] [text "<"]], td [] [text "Left"], td [] [button [onClick LeftEyeRight] [text ">"]]]
                    , tr [] [ td [] [text ""], td [] [button [onClick LeftEyeDown] [text "v"]], td [] [text ""] ]
                    ]
                ]
              , td [] [
                    table [] [
                      tr [] [ td [] [text ""], td [] [button [onClick RightEyeUp] [text "^"]], td [] [text ""] ]
                    , tr [] [ td [] [ button [onClick RightEyeLeft] [text "<"]], td [] [text "Right"], td [] [button [onClick RightEyeRight] [text ">"]]]
                    , tr [] [ td [] [text ""], td [] [button [onClick RightEyeDown] [text "v"]], td [] [text ""] ]
                    ]
                ]
          ]
        ]
        -- , youtube rickrolled
        , br [] []
        , Element.toHtml
          <| Collage.collage model.width model.height
         [ Collage.move (model.leftEyeXY.x, model.leftEyeXY.y) <| Eye.view model.leftEye
         , Collage.move (model.rightEyeXY.x, model.rightEyeXY.y) <| Eye.view model.rightEye
         ]
      ]


-- MAIN


main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init = (model, Task.perform (\_ -> NoOp) (\x -> Resize x) Window.size)

model =
  { leftEye = Eye.init 0.0 0.0
  , rightEye = Eye.init 0.0 0.0
  , width = 0
  , height = 0
  , visibility = Hidden
  , clicks = 0
  , leftEyeXY = {x=leftEyeX, y=leftEyeY}
  , rightEyeXY = {x=rightEyeX, y=rightEyeY}
  }


-- UPDATE


type Msg =  
    NoOp
  | Move Mouse.Position
  | Resize Window.Size
  | Click Mouse.Position
  | LeftEyeLeft
  | LeftEyeRight
  | LeftEyeUp
  | LeftEyeDown
  | RightEyeLeft
  | RightEyeRight
  | RightEyeUp
  | RightEyeDown

movePupils : Model -> Mouse.Position -> Model
movePupils model position =
      { model |
        leftEye = Eye.update
          { mouseX = (toFloat position.x) - (toFloat model.width / 2) - model.leftEyeXY.x
          , mouseY = (toFloat model.height / 2) - (toFloat position.y) - model.leftEyeXY.y
          }
          model.leftEye
        , rightEye = Eye.update
          { mouseX = (toFloat position.x) - (toFloat model.width / 2) - model.rightEyeXY.x
          , mouseY = (toFloat model.height / 2) - (toFloat position.y) - model.rightEyeXY.y
          }
          model.rightEye
      }

update : Msg -> Model -> (Model, Cmd Msg)  
update msg model =  
  case msg of
    NoOp -> (model, Cmd.none)
    Resize newSize ->
        ({ model | width = newSize.width, height = newSize.height, visibility = Visible }, Cmd.none)
    Move position ->
        (movePupils model position, Cmd.none)
    Click position ->
        ({ model | clicks = model.clicks + 1}, Cmd.none)
    LeftEyeLeft ->
        ({ model | leftEyeXY = {x=model.leftEyeXY.x-5, y=model.leftEyeXY.y}}, Cmd.none)
    LeftEyeRight ->
        ({ model | leftEyeXY = {x=model.leftEyeXY.x+5, y=model.leftEyeXY.y}}, Cmd.none)
    LeftEyeUp ->
        ({ model | leftEyeXY = {x=model.leftEyeXY.x, y=model.leftEyeXY.y+5}}, Cmd.none)
    LeftEyeDown ->
        ({ model | leftEyeXY = {x=model.leftEyeXY.x, y=model.leftEyeXY.y-5}}, Cmd.none)
    RightEyeLeft ->
        ({ model | rightEyeXY = {x=model.rightEyeXY.x-5, y=model.rightEyeXY.y}}, Cmd.none)
    RightEyeRight ->
        ({ model | rightEyeXY = {x=model.rightEyeXY.x+5, y=model.rightEyeXY.y}}, Cmd.none)
    RightEyeUp ->
        ({ model | rightEyeXY = {x=model.rightEyeXY.x, y=model.rightEyeXY.y+5}}, Cmd.none)
    RightEyeDown ->
        ({ model | rightEyeXY = {x=model.rightEyeXY.x, y=model.rightEyeXY.y-5}}, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg  
subscriptions model =
    Sub.batch
        [ Mouse.moves Move
        , Mouse.clicks Click
        ]

