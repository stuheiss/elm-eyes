module Eye exposing (init, Model, view, update)

import Color
import Collage


-- CONSTANTS

(eyeWidth, eyeHeight) = (100, 200)

(halfEyeWidth, halfEyeHeight) = (50, 100)

pupilRadius = 20


-- MODEL

type alias Model =
  { pupilX : Float
  , pupilY : Float
  }

init : Float -> Float -> Model
init pupilX pupilY =
  { pupilX = pupilX
  , pupilY = pupilY
  }


-- UPDATE

type alias Action =
  { mouseX : Float
  , mouseY : Float
  }


update : Action -> Model -> Model
update action model =
  let
    (pupilX, pupilY) = constrainCircleToElipse
      action.mouseX
      action.mouseY
      (halfEyeWidth - pupilRadius)
      (halfEyeHeight - pupilRadius)
  in
    { model | pupilX = pupilX, pupilY = pupilY }


-- See http://mathworld.wolfram.com/Ellipse-LineIntersection.html
constrainCircleToElipse : Float -> Float -> Float -> Float -> (Float, Float)
constrainCircleToElipse x_0 y_0 a b =
  let p = x_0^2 / a^2 + y_0^2 / b^2
      q = a * b / sqrt(a^2 * y_0^2 + b^2 * x_0^2)
      x = q * x_0
      y = q * y_0 in
  if p <= 1 then (x_0, y_0) else (x, y)


-- VIEW

view : Model -> Collage.Form
view model =
  Collage.group
    [ Collage.outlined
        (Collage.solid Color.black)
        (Collage.oval eyeWidth eyeHeight)
    , Collage.move
        (model.pupilX, model.pupilY)
        <| Collage.filled Color.black (Collage.circle pupilRadius)
    ]
