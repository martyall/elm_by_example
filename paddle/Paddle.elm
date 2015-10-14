module Paddle where


import Color exposing (blue, green, orange, red, white)
import Graphics.Collage exposing (Form, circle, collage, filled, group,
    move, moveY, rect)
import Graphics.Element exposing (Element, centered, container, empty,
    layers, middle)
import Keyboard
import Signal exposing ((<~), Signal, foldp, merge)
import Text as T
import Time exposing (Time, fps)
import Window


{- draw boders -}
borders : Form
borders =
  group [
    rect 440 440 |> filled blue,
    rect 400 420 |> filled white |> moveY -10
  ]

{- draws paddle -}
paddle : Float -> Form
paddle x =
  rect (toFloat 100) (toFloat 20)
    |> filled green
    |> move (x,-210)


{- draws ball as a function of position -}
ball : Float -> Float -> Form
ball x y = filled orange (circle 10) |> move (x,y)

{- draw the game over frame -}
gameOver : Element
gameOver =
  T.fromString "Game Over"
    |> T.color red
    |> T.bold
    |> T.height 60
    |> centered
    |> container 400 440 middle

{- the state type represents the state of the game -}
{- x y : coordinates of ball
dx dy : ball velocities
paddlex, paddledx : pos and velocity of paddle
isOver: is game over -}
type alias State =
  { x: Float
  , y: Float
  , dx: Float
  , dy: Float
  , paddlex: Float
  , paddledx: Float
  , isOver: Bool
  }

initialState : State
initialState =
  { x = 0
  , y = 0
  , dx = 0.14
  , dy = 0.2
  , paddlex = 0
  , paddledx = 0
  , isOver = False
  }

view : State -> Element
view s =
  layers [
    collage 440 440 [
      borders,
      paddle s.paddlex,
      ball s.x s.y
    ],
    if s.isOver then gameOver else empty
  ]

type Event = Tick Time | PaddleDx Int

clockSignal : Signal Event
clockSignal = Tick <~ fps 100

keyboardSignal : Signal Event
keyboardSignal = (.x >> PaddleDx) <~ Keyboard.arrows

eventSignal : Signal Event
eventSignal = merge clockSignal keyboardSignal

gameSignal : Signal State
gameSignal = foldp step initialState <| eventSignal

step : Event -> State -> State
step event s =
  if s.isOver
     then s
     else case event of
            Tick time ->
              {s |
                 x <- s.x + s.dx*time,
                 y <- s.y + s.dy*time,
                 dx <- if (s.x >= 190 && s.dx > 0) ||
                          (s.x <= -190 &&s.dx < 0 )
                       then -1 * s.dx
                       else s.dx,
                 dy <- if (s.y >= 190 && s.dy > 0) ||
                          (s.y <= -190 &&s.dy < 0 ) &&
                          (s.x >= s.paddlex - 50) &&
                          (s.x <= s.paddlex + 50)
                       then -1 * s.dy
                       else s.dy,
                 paddlex <- ((s.paddlex + s.paddledx*time) `max` -150) `min` 150,
                 isOver <- s.y < -200
              }
            PaddleDx dx -> {s | paddledx <- 0.1 * toFloat dx}

main : Signal Element
main = view <~ gameSignal
