import Face exposing (init, input, update, view)
import StartApp exposing (start)

app =
  StartApp.start
    { init = init
    , inputs = [input]
    , update = update
    , view = view
    }

main =
  app.html
