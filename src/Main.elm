import Face exposing (init, inputs, update, view)
import StartApp exposing (start)

app =
  StartApp.start
    { init = init ()
    , inputs = inputs
    , update = update
    , view = view
    }

main =
  app.html
