module Face where

import Effects
import Eye
import Graphics.Collage
import Html
import Html.Lazy
import Mouse
import Time
import Touch
import Window


-- MODEL

(width, height) = (300, 350)
(halfWidth, halfHeight) = (150, 175)


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


noFx : Model -> (Model, Effects.Effects Action)
noFx model =
   (model, Effects.none)


init : (Model, Effects.Effects Action)
init =
  noFx
    { leftEye = Eye.init 0.0 0.0
    , rightEye = Eye.init 0.0 0.0
    , width = 0
    , height = 0
    , visibility = Hidden
    }


-- UPDATE

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    NoOp -> noFx model
    Dimensions (x, y) -> noFx { model | width = x, height = y, visibility = Visible }
    Click (x, y) -> noFx
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


view : Signal.Address Action -> Model -> Html.Html
view _ model =
  Html.Lazy.lazy viewFace model


-- INPUTS

delta : Signal.Signal Time.Time
delta =
  Signal.map Time.inSeconds (Time.fps 30)


input : Signal.Signal Action
input =
  Signal.sampleOn delta <|
    Signal.mergeMany
      [ Signal.map Dimensions Window.dimensions
      , Signal.map Click Mouse.position
      , Signal.map
          (List.foldr (\t -> \_ -> Click (t.x, t.y)) NoOp)
          Touch.touches
      ]
