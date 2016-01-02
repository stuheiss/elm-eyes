module Face where

import Eye
import Graphics.Collage
import Html
import Html.Lazy
import Mouse
import Signal.Extra
import Touch
import Window


-- MODEL

(leftEyeX, leftEyeY) = (-75, 50)
(rightEyeX, rightEyeY) = (75, 0)


type alias Model =
  { leftEye : Eye.Model
  , rightEye : Eye.Model
  , width : Int
  , height : Int
  , visibility: Visibility
  }


-- Only display the model after an initial `Dimensions' action
type Visibility = Hidden | Visible


type Action =
    NoOp
  | Dimensions (Int, Int)
  | Click (Int, Int)


init : Action -> Model
init action =
  let
    model =
      { leftEye = Eye.init 0.0 0.0
      , rightEye = Eye.init 0.0 0.0
      , width = 0
      , height = 0
      , visibility = Hidden
      }
  in update action model


-- UPDATE

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Dimensions (x, y) ->
      { model | width = x, height = y, visibility = Visible }
    Click (x, y) ->
      { model |
        leftEye = Eye.update
          { mouseX = (toFloat x) - (toFloat model.width / 2) - leftEyeX
          , mouseY = (toFloat model.height / 2) - (toFloat y) - leftEyeY
          }
          model.leftEye,
        rightEye = Eye.update
          { mouseX = (toFloat x) - (toFloat model.width / 2) - rightEyeX
          , mouseY = (toFloat model.height / 2) - (toFloat y) - rightEyeY
          }
          model.rightEye
      }


-- VIEW

view : Model -> Html.Html
view model =
  Html.Lazy.lazy viewFace model


viewFace : Model -> Html.Html
viewFace model =
  case model.visibility of
    Hidden -> Html.div [] []
    Visible ->
      Html.fromElement
        <| Graphics.Collage.collage model.width model.height
       [ Graphics.Collage.move (leftEyeX, leftEyeY) <| Eye.view model.leftEye
       , Graphics.Collage.move (rightEyeX, rightEyeY) <| Eye.view model.rightEye
       ]


-- SIGNALS

main : Signal Html.Html
main =
  Signal.map view model

model : Signal Model
model =
  Signal.Extra.foldp' update init input

input : Signal.Signal Action
input =
  Signal.mergeMany
    [ Signal.map Dimensions Window.dimensions
    , Signal.map Click Mouse.position
    , Signal.map
        (List.foldr (\t -> \_ -> Click (t.x, t.y)) NoOp)
        Touch.touches
    ]
