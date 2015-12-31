module Face where

import Effects
import Eye
import Graphics.Collage
import Html
import Html.Lazy
import Mouse
import Time


-- MODEL

(width, height) = (300, 350)
(halfWidth, halfHeight) = (150, 175)


(leftEyeX, leftEyeY) = (-75, 50)
(rightEyeX, rightEyeY) = (75, 0)


type alias Model =
  { leftEye : Eye.Model
  , rightEye : Eye.Model
  }


type alias Action = (Int, Int)


noFx : Model -> (Model, Effects.Effects Action)
noFx model =
   (model, Effects.none)


init : () -> (Model, Effects.Effects Action)
init () =
  noFx
    { leftEye = Eye.init 0.0 0.0
    , rightEye = Eye.init 0.0 0.0
    }


-- UPDATE

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    (x, y) -> noFx
      { leftEye = Eye.update
          { mouseX = (toFloat x) - halfWidth - leftEyeX
          , mouseY = halfHeight - (toFloat y) - leftEyeY
          }
          model.leftEye,
        rightEye = Eye.update
          { mouseX = (toFloat x) - halfWidth - rightEyeX
          , mouseY = halfHeight - (toFloat y) - rightEyeY
          }
          model.rightEye
      }


-- VIEW

viewFace : Model -> Html.Html
viewFace model =
  Html.fromElement
  <| Graphics.Collage.collage width height
     [ Graphics.Collage.move (leftEyeX, leftEyeY) <| Eye.view model.leftEye
     , Graphics.Collage.move (rightEyeX, rightEyeY) <| Eye.view model.rightEye
     ]


view : Signal.Address Action -> Model -> Html.Html
view _ model =
  Html.Lazy.lazy viewFace model


-- INPUTS

delta : Signal.Signal Time.Time
delta =
  Signal.map Time.inSeconds (Time.fps 30)


inputs : List (Signal.Signal Action)
inputs =
  [ Signal.sampleOn delta Mouse.position ]
